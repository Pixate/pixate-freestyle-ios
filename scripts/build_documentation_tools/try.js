#!/usr/bin/env node

var ValueParser = require('../lib/value-expr-parser').parser,
    TreeLexer = require('../lib/tree-lexer'),
    ValueTreeParser = require('../lib/value-tree-parser').parser,
    flatten = require('../lib/flatten'),
    argv = require('optimist')
        .usage('Parse a value-expression and emit details about it.\n\nusage: $0')
        .boolean(['a', 'd', 'n', 'o', 'p', 's', 't'])
        .demand(1)
        .check(checkArgs)
        .options('a', {
            alias: 'all',
            describe: 'Show all details about the expression'
        })
        .options('d', {
            alias: 'remove-duplicates',
            describe: 'Remove duplicates from output'
        })
        .options('n', {
            alias: 'no-headers',
            describe: 'Turn off headers in output'
        })
        .options('o', {
            alias: 'output',
            describe: 'Output all possible values of the expression'
        })
        .options('p', {
            alias: 'parse-results',
            describe: 'Show the result of parsing the expression (aka. AST)'
        })
        .options('s', {
            alias: 'source',
            describe: 'Show the type expression being processed'
        })
        .options('t', {
            alias: 'tree-results',
            describe: 'Show the result of converting the AST to an Iterator'
        })
        .argv;

for (var i = 0; i < argv._.length; i++) {
    // source
    var source = argv._[i];

    if (argv.a || argv.s) {
        showHeader("Source");
        console.log(source);
    }

    // source -> AST
    var result = ValueParser.parse(source);

    if (argv.a || argv.p) {
        showHeader("Parse Result");
        console.log("ast = %s", JSON.stringify(result, null, 2));
    }

    // AST -> Iterator
    var treeResult = ValueTreeParser.parse(result);

    if (argv.a || argv.t) {
        showHeader("Tree Parse Result");
        console.log("tree = %s", JSON.stringify(treeResult, null, 2));
    }

    // Iterator -> console.log
    if (argv.a || argv.o) {
        showHeader("Output");
        if (typeof treeResult === "string") {
            console.log(treeResult);
        }
        else {
            var seen = {};

            treeResult.forEach(function(item, index) {
                var text;

                if (Array.isArray(item)) {
                    var flattened = flatten(item)
                    var filtered = flattened.filter(function(item) { return item !== null && item !== "" });

                    text = filtered.join(" ").replace(/^\s+/, "");
                }
                else {
                    text = item;
                }

                if (argv.d === false || seen.hasOwnProperty(text) === false) {
                    console.log(text);
                    seen[text] = true;
                }
            });
        }
    }
}

function showHeader(header) {
    if (!argv.n) {
        console.log();
        console.log(header);
        console.log(new Array(header.length + 1).join("="));
    }
}

function checkArgs(args) {
    var atLeastOneArg = false;

    for (var arg in args) {
        if (arg !== "_" && arg !== "$0" && args[arg]) {
            atLeastOneArg = true;
            break;
        }
    }

    if (atLeastOneArg === false) {
        args.o = true;
    }

    return true;
}
