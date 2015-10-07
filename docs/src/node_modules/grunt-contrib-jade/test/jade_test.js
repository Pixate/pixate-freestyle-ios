var grunt = require('grunt');

exports.jade = {
  compile: function(test) {
    'use strict';

    test.expect(5);

    var actual = grunt.file.read('tmp/jade.html');
    var expected = grunt.file.read('test/expected/jade.html');
    test.equal(expected, actual, 'should compile jade templates to html');

    actual = grunt.file.read('tmp/jade2.html');
    expected = grunt.file.read('test/expected/jade2.html');
    test.equal(expected, actual, 'should compile jade templates to html (multiple files support)');

    actual = grunt.file.read('tmp/jadeInclude.html');
    expected = grunt.file.read('test/expected/jadeInclude.html');
    test.equal(expected, actual, 'should compile jade templates to html with an include');

    actual = grunt.file.read('tmp/jadeTemplate.html');
    expected = grunt.file.read('test/expected/jadeTemplate.html');
    test.equal(expected, actual, 'should compile jade templates to html with grunt template support');

    actual = grunt.file.read('tmp/jadeDynamicData.html');
    expected = grunt.file.read('test/expected/jadeDynamicData.html');
    test.equal(expected, actual, 'should allow options.data to be a function');

    test.done();
  }
};