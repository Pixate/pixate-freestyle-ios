#!/usr/bin/env node

var ValueParser = require('./lib/value-expr-parser').parser,
    stringHash = require('string-hash');

var docs = require('../documentation');
var type_values = require('../type_values');
var expressions = {};

function addExpression(property) {
    if (property !== null && property.source !== "") {
        expressions[property.source] = true;
    }
}

function expand(expression) {
    var result = "";
    var expandedValue = expression;

    while (expandedValue !== result) {
        result = expandedValue;
        expandedValue = result.replace(/<([-_a-zA-Z]+)>/g, function(typeRef, typeName) {
            if (type_values.hasOwnProperty(typeName)) {
                return "[" + type_values[typeName] + "]";
            }
            else {
                console.error("ERROR: unknown type-ref '%s'", typeRef);
                return typeRef;
            }
        });
    }

    return result;
}

function parse(expression) {
    try {
        return ValueParser.parse(expression);
    }
    catch(e) {
        console.error("Error parsing '%s'\n", expression);
        console.error(e);

        return null;
    }
}

// collect styler type expressions

Object.keys(docs.stylers).forEach(function(stylerName) {
    var styler = docs.stylers[stylerName];

    Object.keys(styler.properties).forEach(function(propertyName) {
        addExpression(styler.properties[propertyName]);
    });
});

// collect control type expressions

Object.keys(docs.controls).forEach(function(controlName) {
    var control = docs.controls[controlName];

    Object.keys(control.properties).forEach(function(propertyName) {
        addExpression(control.properties[propertyName]);
    });
});

// collection type expressions

Object.keys(type_values).forEach(function(valueName) {
    expressions[type_values[valueName]] = true;
});

// create aggregate

var result = {};

Object.keys(expressions).sort().forEach(function(expression) {
    var minified = expression.replace(/\s+/g, "");
    var expansion = expand(expression);

    result[minified] = {
        source: expression,
        expansion: expansion,
        hash: stringHash(minified),
        ast: parse(expansion)
    };
});

console.log(JSON.stringify(result, null, 2));
