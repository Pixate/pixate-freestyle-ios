#!/usr/bin/env node

var Parser = require('jison').Parser;

var grammar = {
    lex: {
        rules: [
            [ "(\\s|[\\r\\n])+", "/* skip whitespace */" ],
            [ "//.*$", "/* skip comments */" ],
            [ "[-_a-zA-Z][-_a-zA-Z0-9]*", "return 'IDENTIFIER';" ],
            [ "<[-_a-zA-Z]+>", "return 'TYPE';" ],
            [ "\"[^\"]+\"", "return 'STRING';" ],
            [ "'[^']+'", "return 'STRING';" ],
            [ "‘[^‘]*‘", "return 'STRING';" ],
            [ "\\|\\|", "return 'IOR';" ],
            [ "\\|", "return 'XOR';" ],
            [ "&&", "return 'PERMUTE'; "],
            [ "\\*", "return 'ZERO_OR_MORE'; "],
            [ "\\+", "return 'ONE_OR_MORE'; "],
            [ "\\?", "return 'ZERO_OR_ONE'; "],
            [ "{", "return 'LCURLY'; "],
            [ "}", "return 'RCURLY'; "],
            [ "\\[", "return 'LBRACKET'; "],
            [ "]", "return 'RBRACKET'; "],
            [ "(0|[1-9][0-9]*)(\\.[0-9]+)?", "return 'NUMBER'; "],
            [ "#", "return 'COMMA_LIST'; "],
            [ ",", "return 'COMMA'; "],
            [ "$", "return 'EOF';" ]
        ]
    },
    bnf: {
        expression: [
            [ "ior_expr EOF", "return $1;" ]
        ],
        ior_expr: [
            [ "xor_expr IOR ior_expr", "$$ = yy.combineBinaryExpression('ior', $1, $3);" ],
            [ "xor_expr", "$$ == $1;" ],
        ],
        xor_expr: [
            [ "permuted_expr XOR xor_expr", "$$ = yy.combineBinaryExpression('xor', $1, $3);" ],
            [ "permuted_expr", "$$ == $1;" ],
        ],
        permuted_expr: [
            [ "and_expr PERMUTE permuted_expr", "$$ = yy.combineBinaryExpression('permute', $1, $3);" ],
            [ "and_expr", "$$ == $1;" ],
        ],
        and_expr: [
            [ "closure_expr and_expr", "$$ = yy.combineBinaryExpression('and', $1, $2);" ],
            [ "closure_expr", "$$ == $1;" ],
        ],
        closure_expr: [
            [ "term", "$$ = $1;" ],
            [ "term ZERO_OR_MORE", "$$ = { '*': $1 };" ],
            [ "term ONE_OR_MORE", "$$ = { '+': $1 };" ],
            [ "term ZERO_OR_ONE", "$$ = { '?': $1 };" ],
            [ "term COMMA_LIST", "$$ = { '#': $1 };" ],
            [ "term LCURLY NUMBER RCURLY", "$$ = { range: { start: parseInt($3), end: parseInt($3), expression: $1 } };" ],
            [ "term LCURLY NUMBER COMMA NUMBER RCURLY", "$$ = { range: { start: parseInt($3), end: parseInt($5), expression: $1 } };" ]
        ],
        term: [
            [ "IDENTIFIER", "$$ = { identifier: $1 };" ],
            [ "TYPE", "$$ = { type: $1.substr(1, $1.length - 2) };" ],
            [ "STRING", "$$ = { string: $1.substr(1, $1.length - 2) };" ],
            [ "NUMBER", "$$ = { identifier: $1 };" ],
            [ "LBRACKET ior_expr RBRACKET", "$$ = { group: $2 };" ]
        ]
    }
};

var parser = new Parser(grammar);

/**
 *  Combine the left-hand and right-hand sides of a binary operator.
 *  However, expression trees don't need to be binary. This function
 *  will combine right's children with left if right's operators is
 *  of the same operator type we're genrating. This reduces the depth
 *  of the tree
 */
parser.yy.combineBinaryExpression = function(operator, left, right) {
    var result = {};

    if (right.hasOwnProperty(operator)) {
        var children = [left];

        right[operator].forEach(function(child) {
            children.push(child);
        });

        result[operator] = children;
    }
    else {
        result[operator] = [left, right];
    }

    return result;
};

// console.log(parser.generate());

// node types
var AND = "and";
var PERMUTED_AND = "permute";
var INCLUSIVE_OR = "ior";
var EXCLUSIVE_OR = "xor";
var GROUP = "group";
var IDENTIFIER = "identifier";
var TYPE = "type";
var STRING = "string";
var ZERO_OR_ONE = "?";
var ZERO_OR_MORE = "*";
var ONE_OR_MORE = "+";
var RANGE = "range";
var COMMA_LIST = "#";

function getNodeType(node) {
    var result = [];

    for (p in node) {
        if (node.hasOwnProperty(p)) {
            result.push(p);
        }
    }

    return (result.length > 0) ? result[0] : null;
}

function joinChildrenSource(children, operator) {
    var parts = [];

    children.forEach(function(child) {
        toSource(child, parts);
    });

    return parts.join(operator);
}

function toSource(node) {
    var parts = (arguments.length == 2) ? arguments[1] : [];
    var type = getNodeType(node);

    switch (type) {
        case AND:
            parts.push(joinChildrenSource(node[type], " "));
            break;

        case PERMUTED_AND:
            parts.push(joinChildrenSource(node[type], " && "));
            break;

        case INCLUSIVE_OR:
            parts.push(joinChildrenSource(node[type], " || "));
            break;

        case EXCLUSIVE_OR:
            parts.push(joinChildrenSource(node[type], " | "));
            break;

        case GROUP:
            parts.push("[" + toSource(node[type]) + "]");
            break;

        case IDENTIFIER:
            parts.push(node[type]);
            break;

        case TYPE:
            parts.push("<" + node[type] + ">");
            break;

        case STRING:
            parts.push('"' + node[type] + '"');
            break;

        case ZERO_OR_ONE:
        case ZERO_OR_MORE:
        case ONE_OR_MORE:
        case COMMA_LIST:
            parts.push(toSource(node[type]) + type);
            break;

        case RANGE:
            var range = node[type];

            parts.push(toSource(range.expression) + "{" + range.start + "," + range.end + "}");
            break;

        default:
            throw new Error("Unknown node type: " + type);
            break;
    }

    return parts.join(" ");
}

// export methods
exports.parser = parser;
exports.toSource = toSource;
exports.getNodeType = getNodeType;
exports.NODE_TYPES = {
    AND: AND,
    PERMUTED_AND: PERMUTED_AND,
    INCLUSIVE_OR: INCLUSIVE_OR,
    EXCLUSIVE_OR: EXCLUSIVE_OR,
    GROUP: GROUP,
    IDENTIFIER: IDENTIFIER,
    TYPE: TYPE,
    STRING: STRING,
    ZERO_OR_ONE: ZERO_OR_ONE,
    ZERO_OR_MORE: ZERO_OR_MORE,
    ONE_OR_MORE: ONE_OR_MORE,
    RANGE: RANGE,
    COMMA_LIST: COMMA_LIST
};
