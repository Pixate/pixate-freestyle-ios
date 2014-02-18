
function SectionProcessor() {
    this.handlers = [];
}

SectionProcessor.prototype.addHandler = function(pattern, callback) {
    this.handlers.push({
        pattern: pattern,
        callback: callback
    });
};

SectionProcessor.prototype.processSections = function(sections) {
    for (var section in sections) {
        var processed = false;

        this.handlers.forEach(function(handler) {
            if (handler.pattern.test(section)) {
                processed = true;
                handler.callback(section, sections[section]);
            }
        });

        if (processed === false) {
            console.log("Unhandled section: '%s'", section);
        }
    }
};

module.exports = SectionProcessor;
