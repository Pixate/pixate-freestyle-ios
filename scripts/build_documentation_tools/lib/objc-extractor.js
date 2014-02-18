// export methods

function extractMethod(source, method) {
    var method = new RegExp("^[-+].+" + method + "\\b(?:.|[\\r\\n])*?^}", "m");
    var match;
    var result = "";

    if ((match = method.exec(source)) !== null) {
        result = match[0];
    }

    return result;
}

function extractStyler(source, styler) {
    var block = new RegExp("^\\s*(\\[\\[" + styler + "\\b(?:.|[\\r\\n])*?^\\s*}\\])", "m");
    var match;
    var result = ""

    if ((match = block.exec(source)) !== null) {
        result = match[1];
    }

    return result;
}

exports.extractMethod = extractMethod;
exports.extractStyler = extractStyler;
