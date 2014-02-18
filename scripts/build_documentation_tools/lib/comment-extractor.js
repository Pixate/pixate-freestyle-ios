// export methods

function getDocumentationComments(source) {
    var comments = /\/\*\*(?!\*)(?:.|[\r\n])*?\*\//g;
    var match;
    var result = [];

    while ((match = comments.exec(source)) !== null) {
        result.push(cleanComment(match[0]));
    }

    return result;
};


function getMultilineComments(source) {
    var comments = /\/\*(?!\*)(?:.|[\r\n])*?\*\//g;
    var match;
    var result = [];

    while ((match = comments.exec(source)) !== null) {
        result.push(cleanComment(match[0]));
    }

    return result;
};

function cleanComment(comment) {
    // convert to lines
    var lines = comment.split(/\r\n?|\n/g);

    // remove first and last lines
    lines.pop();
    lines.shift();

    // container for cleaned up lines
    var cleanLines = [];

    lines.forEach(function(line) {
        cleanLines.push(line.replace(/^\s*\*\s*/, ''));
    });

    // rejoin lines
    var cleanedComment = cleanLines.join('\n');

    // remove leading and trailing whitespace
    return cleanedComment.replace(/^\s+/, '').replace(/\s+$/, '');
};

exports.getDocumentationComments = getDocumentationComments;
exports.getMultilineComments = getMultilineComments;
exports.cleanComment = cleanComment;
