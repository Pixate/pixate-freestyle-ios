#!/usr/bin/env node

var fs               = require('fs'),
    path             = require('path'),
    findSync         = require('./lib/find').findSync,
    commentExtractor = require('./lib/comment-extractor'),
    extractSections  = require('./lib/section-extractor'),
    objcExtractor    = require('./lib/objc-extractor'),
    SectionProcessor = require('./lib/section-processor'),
    ValueTypeParser  = require('./lib/value-expr-parser').parser;

// helper functions

function collectProperty(property, container, comment) {
    var match = /^([^\s:]+)\s*:\s*(.*)\s*$/.exec(property);

    if (match !== null) {
        var propertyName = match[1];
        var typeExpression = match[2];
        var valueTypeExpression;

        try {
            valueTypeExpression = (typeExpression !== "") ? ValueTypeParser.parse(typeExpression) : null;
        }
        catch (e) {
            valueTypeExpression = "unknown<" + typeExpression + ">";
        }

        container[propertyName] = {
            source: typeExpression,
            ast: valueTypeExpression
        };

        if (comment !== undefined) {
            container[propertyName].comment = comment;
        }
    }
    else if (property !== null && property !== "") {
        console.error("Unrecognized property format: '%s'", property);
        container[property] = null;
    }
}

function collectStylerOrProperty(items, container) {
    items.forEach(function(propertyOrStyler) {
        var commentBegin = propertyOrStyler.indexOf("//");
        var comment = undefined;

        if (commentBegin != -1) {
            comment = propertyOrStyler.substring(commentBegin + 2).trim();
            propertyOrStyler = propertyOrStyler.replace(/\s*\/\/.*$/, "");
        }
        if (/Styler$/.test(propertyOrStyler)) {
            if (!ignoredStylers.hasOwnProperty(propertyOrStyler)) {
                container.stylers.push(propertyOrStyler);
            }
        }
        else {
            collectProperty(propertyOrStyler, container.properties, comment);
        }
    });
}

function sectionsToControlInfo(sections) {
    var info = {
        stylers: [],
        properties: {},
        children: {}
    };
    var processor = new SectionProcessor();

    processor.addHandler(/element name/, function(section, value) {
        info.elementName = value[0];
    });
    processor.addHandler(/properties/, function(section, value) {
        var match = /\w+\W+([-a-zA-Z_]+)/.exec(section);
        var foundChild = false;

        if (match !== null) {
            var childName = match[1];

            if (info.children.hasOwnProperty(childName)) {
                foundChild = true;
                collectStylerOrProperty(value, info.children[childName]);
            }
        }

        if (foundChild === false) {
            collectStylerOrProperty(value, info);
        }
    });
    processor.addHandler(/pseudo-class/, function(section, value) {
        var match = /\w+\W+([-a-zA-Z_]+)/.exec(section);
        var foundChild = false;

        if (match !== null) {
            var childName = match[1];

            if (info.children.hasOwnProperty(childName)) {
                foundChild = true;
                info.children[childName].pseudoClasses = value;
            }
        }

        if (foundChild === false) {
            info.pseudoClasses = value;
        }
    });
    processor.addHandler(/children/, function(section, value) {
        value.forEach(function(child) {
            // some children are markdown links. Extract the name in those cases
            var childName = child.replace(/^\[([^\]]+)\]\([^\)]+\)$/, function(match, p1) { return p1; });

            // some child names have inline (JS-style) comments
            if (childName.indexOf("//") != -1) {
                childName = childName.replace(/\s*\/\/.*$/, "");
            }

            info.children[childName] = {
                elementName: childName,
                type: "view",
                stylers: [],
                properties: {}
            };
        });
    });
    processor.addHandler(/^NOTE:/, function(section, value) {
        if (info.hasOwnProperty("note") === false) {
            info.note = [];
        }
        info.note.push(section.replace(/^NOTE:\s+/, ''));
    });

    processor.processSections(sections);

    return info;
}

function processStyler(fullPath, directory, file) {
    var extensionPattern = /\.m$/;

    if (extensionPattern.test(file)) {
        var stylerName = file.replace(extensionPattern, '');

        if (!ignoredStylers.hasOwnProperty(stylerName)) {
            var source = fs.readFileSync(fullPath).toString();
            var method = objcExtractor.extractMethod(source, "declarationHandlers");
            var property = /@"((?:[^"]|\\")*)"\s*:/g;
            var properties = {};

            while ((match = property.exec(method)) !== null) {
                properties[match[1]] = null;
            }

            // extract additional info from header
            var header = fullPath.replace(extensionPattern, ".h");

            if (fs.existsSync(header)) {
                var headerSource = fs.readFileSync(header).toString();
                var docs = commentExtractor.getDocumentationComments(headerSource);

                if (docs.length > 0) {
                    docs[0].split(/\n/).forEach(function(property) {
                        // Not elegant, but this chops off the "- " text before the declaration
                        collectProperty(property.substring(2), properties);
                    });
                }
            }

            stylerInfos[stylerName] = {
                type: "styler",
                properties: properties
            };
        }
    }
}

function processControl(fullPath, directory, file) {
    var extensionPattern = /\.m$/;

    if (extensionPattern.test(file)) {
        var controlName = file.replace(extensionPattern, '');

        if (!ignoredControls.hasOwnProperty(controlName)) {
            var source = fs.readFileSync(fullPath).toString();

            // extract list of stylers
            var method = objcExtractor.extractMethod(source, "viewStylers");
            var styler = /^\s*(?:\[\[)?(PX.*?Styler)\b/mg;
            var stylers = [];

            while ((match = styler.exec(method)) !== null) {
                var stylerName = match[1];

                if (!ignoredStylers.hasOwnProperty(stylerName)) {
                    stylers.push(stylerName);
                }
            }

            // extract list of properties
            var genericStyler = objcExtractor.extractStyler(method, "PXGenericStyler");
            var property = /@"((?:[^"]|\\")*)"\s*:/g;
            var properties = {};

            while ((match = property.exec(method)) !== null) {
                properties[match[1]] = null;
            }

            var info = {
                type: "view",
                stylers: stylers,
                properties: properties,
                children: []
            };

            controlInfos[controlName] = info;

            // extract additional info from header
            var header = fullPath.replace(extensionPattern, ".h");

            if (fs.existsSync(header)) {
                var headerSource = fs.readFileSync(header).toString();
                var docs = commentExtractor.getDocumentationComments(headerSource);

                if (docs.length > 0) {
                    var sectionInfo = sectionsToControlInfo(extractSections(docs[0]));

                    for (p in sectionInfo) {
                        if (p === "children") {
                            for (child in sectionInfo[p]) {
                                info.children.push(child);
                                controlInfos[controlName + '.' + child] = sectionInfo[p][child];
                            }
                        }
                        else if (p === "properties") {
                            // merge
                            for (property in sectionInfo[p]) {
                                info.properties[property] = sectionInfo[p][property];
                            }
                        }
                        else if (p === "stylers") {
                            // TODO: make sure header styler list matches what we got from code
                        }
                        else {
                            info[p] = sectionInfo[p];
                        }
                    }
                }
            }
        }
    }
}

// main
var frameworkDirectory;

if (process.argv.length == 2) {
    console.log("usage: collect_documentation <pixate-ios-framework-path>?");
    console.log("  pixate-ios-framework-path is the full path to your local copy of the pixate-ios-framework repository.");
    console.log("  If you have defined PIXATE_PROJECTS_HOME to point to the root of your Pixate repos, then you can omit");
    console.log("  this argument");
    console.log();
    console.log("  Once all stylers and controls in the framework path have been processed, a JSON object will be emitted");
    console.log("  containing the stylers, controls, and their associated metadata.");
    process.exit(1);
}
else {
    frameworkDirectory = process.argv[2];
}

// setup the relevant paths
var stylingDirectory = path.join(frameworkDirectory, 'Styling');
var controlsDirectory = path.join(stylingDirectory, 'Controls');
var stylersDirectory = path.join(stylingDirectory, 'Stylers');

// setup sets for controls and stylers that we'd like to ignore
var ignoredControls = {
    "PXMKAnnotationContainerView": true,
    "PXVirtualStyleableControl": true,
    "PXUILayoutContainerView": true,
    "PXUITableViewCellContentView": true
};
var ignoredStylers = {
    "PXStylerBase": true,
    "PXStylerContext": true,
    "PXGenericStyler": true,
    "PXInsetStyler": true
}
// setup containers for styler and control metadata
var stylerInfos = {};
var controlInfos = {};
var combined = {
  stylers: stylerInfos,
  controls: controlInfos
}

// process all stylers and controls
findSync(stylersDirectory, processStyler);
findSync(controlsDirectory, processControl);

// emit the results
console.log(JSON.stringify(combined, null, 2));
