// export methods

function extractSections(source) {
    // convert to lines
    var lines = source.split(/\r\n?|\n/g);
    var section = "";
    var result = {};

    lines.forEach(function(line) {
        if (/^\s*$/.test(line)) {
            // skip empty lines
        }
        else if (/^[^-]/.test(line)) {
            section = line;
            result[section] = [];
        }
        else if (/^-/.test(line)) {
            result[section].push(line.replace(/^\s*-\s*/, ''));
        }
    });

    return result;
}

module.exports = extractSections;
