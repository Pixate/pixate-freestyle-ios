#!/usr/bin/env node

var valueTypeParser = require('./lib/value-expr-parser'),
    NODE_TYPES = valueTypeParser.NODE_TYPES,
    argv = require('optimist')
        .usage('Generate stats and other useful information by processing documentation.json\n\nusage $0')
        .boolean(['a', 'c', 'n', 's', 't', 'o'])
        .demand(1)
        .check(checkArgs)
        .options('a', {
            alias: 'all',
            describe: 'Show all details'
        })
        .options('c', {
            alias: 'controls',
            describe: 'Show JSON of all controls, with expanded property list'
        })
        .options('n', {
            alias: 'no-headers',
            describe: 'Turn off headers in output'
        })
        .options('s', {
            alias: 'stylers',
            describe: 'Show JSON of all stylers'
        })
        .options('t', {
            alias: 'symbol-table',
            describe: 'Show symbol table along with their frequencies'
        })
        .options('o', {
            alias: 'summary',
            describe: 'Output summary stats'
        })
        .argv;

// globals
var propertiesByControl = {};
var globalPropertySet = {};
var symbolTable = { properties: {}, pseudoClasses: {}, types: {}, identifiers: {}, strings: {} };

// helper functions

function checkArgs(args) {
    var atLeastOneArg = false;

    for (var arg in args) {
        if (arg !== "_" && arg !== "$0" && args[arg]) {
            atLeastOneArg = true;
            break;
        }
    }

    return atLeastOneArg;
}

function showHeader(header) {
    if (!argv.n) {
        console.log();
        console.log(header);
        console.log(new Array(header.length + 1).join("="));
    }
}

function updateSymbolTable(category, value) {
    if (category.hasOwnProperty(value)) {
        category[value]++;
    }
    else {
        category[value] = 1;
    }
}

function collectLeaves(node, info) {
    if (node === null) return;

    var type = valueTypeParser.getNodeType(node);

    switch (type) {
        case NODE_TYPES.INCLUSIVE_OR:
        case NODE_TYPES.EXCLUSIVE_OR:
        case NODE_TYPES.AND:
        case NODE_TYPES.PERMUTED_AND:
            node[type].forEach(function(child) { collectLeaves(child, info) });
            break;

        case NODE_TYPES.ZERO_OR_ONE:
        case NODE_TYPES.ZERO_OR_MORE:
        case NODE_TYPES.ONE_OR_MORE:
        case NODE_TYPES.GROUP:
        case NODE_TYPES.COMMA_LIST:
            collectLeaves(node[type], info);
            break;

        case NODE_TYPES.RANGE:
            var range = node[type];

            collectLeaves(range.expression, info);
            break;

        case NODE_TYPES.IDENTIFIER:
        case NODE_TYPES.TYPE:
        case NODE_TYPES.STRING:
            updateSymbolTable(info[type + "s"], node[type]);
            break;

        default:
            console.error("Unknown node type '%s'", type);
            console.error(JSON.stringify(node, null, 2));
            break;
    }
}

function processProperties(container, set) {
    for (var propertyName in container.properties) {
        // grab the property
        var property = container.properties[propertyName];

        // transfer over the property's syntax
        var value = { syntax: (property !== null && "source" in property) ? property.source : "" };

        // attach comment, if we have one
        if (property !== null && "comment" in property) {
            value.comment = property.comment;
        }

        // attach new value
        set[propertyName] = value;

        updateSymbolTable(symbolTable.properties, propertyName);

        var property = container.properties[propertyName];

        if (property !== null) {
            collectLeaves(property.ast, symbolTable);
        }
    }
}

// main

var docs = require(argv._[0]);
var controls = docs.controls
var stylers = docs.stylers;

for (var controlName in controls) {
    var control = controls[controlName];
    var set = {};

    // add styler properties
    control.stylers.forEach(function(stylerName) {
        if (stylers.hasOwnProperty(stylerName)) {
            var styler = stylers[stylerName];

            processProperties(styler, set);
        }
        else {
            console.error('Cannot locate styler "%s"', stylerName);
        }
    });

    // add locally-defined properties
    processProperties(control, set);

    // add pseudo-classes
    if (control.hasOwnProperty("pseudoClasses")) {
        control.pseudoClasses.forEach(function(pseudoClass) {
            updateSymbolTable(symbolTable.pseudoClasses, pseudoClass);
        });
    }

    // save result
    propertiesByControl[controlName] = {
        elementName: control.elementName,
        properties: set
    };
}

// show controls
if (argv.a || argv.c) {
    showHeader("Controls");
    console.log(JSON.stringify(propertiesByControl, null, 2));
}

// show stylers
if (argv.a || argv.s) {
    showHeader("Stylers");
    console.log(JSON.stringify(stylers, null, 2));
}

// show symbol table
if (argv.a || argv.t) {
    showHeader("Symbol Table");
    console.log(JSON.stringify(symbolTable, null, 2));
}

// show some stats
if (argv.a || argv.o) {
    var controlCount = 0;
    var propertyCount = 0;

    for (var controlName in propertiesByControl) {
        var control = propertiesByControl[controlName];
        var propertyNames = control.properties;

        controlCount++;
        propertyCount += Object.keys(propertyNames).length;
    }

    var propertyNames = Object.keys(symbolTable.properties);
    var pseudoClassNames = Object.keys(symbolTable.pseudoClasses);
    var typeNames = Object.keys(symbolTable.types);
    var identifierNames = Object.keys(symbolTable.identifiers);
    var stringNames = Object.keys(symbolTable.strings);

    showHeader("Summary");
    console.log("     Control count = %d", controlCount);
    console.log("    Property count = %d", propertyCount);
    console.log("Properties/Control = %d", Math.round(100.0 * propertyCount / controlCount)/ 100.0);
    console.log(" Unique Properties = %d", propertyNames.length);
    console.log("    Pseudo-classes = %d", pseudoClassNames.length);
    console.log("             Types = %d", typeNames.length);
    console.log("       Identifiers = %d", identifierNames.length);
    console.log("           Strings = %d", stringNames.length);
}
