#!/usr/bin/env node

var Parser = require('jison').Parser,
    TreeLexer = require('./tree-lexer'),
    Iterators = require('kld-array-iterators');

var grammar = {
    tokens: [
        'ior', 'xor', 'permute', 'and',
        'group',
        'range', '?', '*', '+', '#',
        'identifier', 'string', 'type',
        'UP', 'DOWN', 'EOF'
    ],
    bnf: {
        root: [
            [ "expression EOF", "return $1" ]
        ],
        expression: [
            [ "group DOWN children UP",     "$$ = $3[0];" ],
            [ "? DOWN children UP",         "$$ = new yy.RepeatIterator(yy.ensureIterator($3[0]), 0, 1);" ],
            [ "* DOWN children UP",         "$$ = new yy.RepeatIterator(yy.ensureIterator($3[0]), 0, 4);" ],
            [ "+ DOWN children UP",         "$$ = new yy.RepeatIterator(yy.ensureIterator($3[0]), 1, 4);" ],
            [ "# DOWN children UP",         "$$ = yy.commaListIterator($3[0], 0, 4);" ],
            [ "range DOWN children UP",     "$$ = new yy.RepeatIterator(yy.ensureIterator($3[0]), $1.start, $1.end);" ],
            [ "binaryOp DOWN children UP",  "$$ = new yy[$1]($3);" ],
            [ "identifier",                 "$$ = $1;" ],
            [ "string",                     "$$ = $1;" ],
            [ "type",                       "$$ = '<' + $1 + '>';" ]
        ],
        binaryOp: [
            [ "ior",        "$$ = 'SubsetIterator';" ],
            [ "xor",        "$$ = 'Iterator';" ],
            [ "permute",    "$$ = 'PermutationIterator';" ],
            [ "and",        "$$ = 'CrossProductIterator';" ]
        ],
        children: [
            [ "children expression",    "$1.push($2); $$ = $1;" ],
            [ "expression",             "$$ = [$1];" ]
        ]
    }
}

var parser = new Parser(grammar);

parser.lexer = new TreeLexer();
parser.yy = Iterators;
parser.yy.ensureIterator = function(item) {
    if (typeof item === "string") {
        return new Iterators.Iterator(item);
    }
    else {
        return item;
    }
}
parser.yy.commaListIterator = function(item, low, high) {
    return new Iterators.CrossProductIterator(
        item,
        new Iterators.RepeatIterator(
            new Iterators.CrossProductIterator(
                ',',
                item
            ),
            low,
            high
        )
    );
}

exports.parser = parser;
