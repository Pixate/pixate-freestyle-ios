#!/usr/bin/env node

var controls = require('../expanded-controls'),
    expressions = require('../expressions'),
    fs = require('fs'),
    Mustache = require('mustache'),
    ValueTreeParser = require('../lib/value-tree-parser').parser,
    flatten = require('../lib/flatten');

// globals

var template = fs.readFileSync('./templates/css.mustache').toString();
var compiledTemplate = Mustache.compile(template);
var nameFromControlName = {};

// helper functions

function emitTemplate(selector, propertyName, value) {
    var ruleset = {
        selector: selector,
        declarations: [
            {
                property: propertyName,
                value: value
            }
        ]
    };

    console.log(compiledTemplate(ruleset));
}

// main

Object.keys(controls).forEach(function(controlName) {
    var control = controls[controlName];
    var selector = control.elementName;

    if (controlName.indexOf('.') === -1) {
        nameFromControlName[controlName] = selector;
    }
    else {
        var names = controlName.split(/\./);

        // remove last item
        nameFromControlName[names.pop()] = selector;

        // convert control names to element names
        var elements = names.map(function(name) {
            return nameFromControlName[name];
        });

        // add this item's name
        elements.push(selector);

        // generate selector
        selector = elements.join(" > ");
    }

    Object.keys(control.properties).forEach(function(propertyName) {
        var expression = control.properties[propertyName];
        var minified = expression.replace(/\s+/g, "");

        if (minified in expressions) {
            var expression = expressions[minified];
            var hash = expression.hash;
            var iterator = ValueTreeParser.parse(expression.ast);

            if (typeof iterator === "string") {
                emitTemplate(selector, propertyName, iterator)
            }
            else {
                var items = iterator.take(10);
                var seen = {};

                // iterator.forEach(function(item) {
                items.forEach(function(item) {
                    var value;

                    if (Array.isArray(item)) {
                        var flattened = flatten(item)
                        var filtered = flattened.filter(function(item) {
                            return item !== null && item !== ""
                        });

                        value = filtered.join(" ").replace(/^\s+/, "");
                    }
                    else {
                        value = item;
                    }

                    if (seen.hasOwnProperty(value) === false) {
                        emitTemplate(selector, propertyName, value);
                        seen[value] = true;
                    }
                });
            }
        }
        else {
            console.error("Missing expression for %s.%s", controlName, propertyName);
        }
    });
});
