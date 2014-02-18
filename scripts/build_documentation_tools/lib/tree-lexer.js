
var scalarNodeTypes = {
    string: true
};

function TreeLexer() {
    this.setInput();
}

TreeLexer.prototype.lex = function() {
    if (this.index < this.lexemes.length) {
        var lexeme = this.lexemes[this.index++];

        this.yytext = lexeme.value;

        return lexeme.type;
    }
    else {
        this.yytext = null;

        return 'EOF';
    }
};

TreeLexer.prototype.setInput = function(node) {
    if (node !== undefined && node !== null) {
        this.lexemes = [];
        buildLexemes(node, this.lexemes);
        this.index = 0;
    }
    else {
        this.lexemes = [];
        this.index = 0;
    }
};

// helper functions
function buildLexemes(node, accumulator) {
    var keys = Object.keys(node);

    switch (keys.length) {
        case 0:
            throw new TypeError("Expected at least one key on node: %s", node);

        case 1:
            var key = keys[0];
            var value = node[key];

            accumulator.push({ type: key, value: value });

            if (Array.isArray(value)) {
                accumulator.push({ type: 'DOWN', value: null });
                value.forEach(function(child) { buildLexemes(child, accumulator); });
                accumulator.push({ type: 'UP', value: null });
            }
            else if (scalarNodeTypes.hasOwnProperty(typeof value) === false) {
                accumulator.push({ type: 'DOWN', value: null });
                buildLexemes(value, accumulator);
                accumulator.push({ type: 'UP', value: null });
            }
            break;

        default:
            if (node.hasOwnProperty('expression')) {
                buildLexemes(node.expression, accumulator);
            }
            else {
                throw new TypeError("Expected an 'expression' property on node: %s", node);
            }
            break;
    }
}

// expose class
module.exports = TreeLexer;
