// export methods

var fs = require('fs'),
    path = require('path')

exports.findSync = function(directory, fileCallback) {
    var files = fs.readdirSync(directory);

    for (var i in files) {
      var fileName = files[i];
      var filePath = path.join(directory, fileName);
      var stats = fs.statSync(filePath);

      if (stats.isFile()) {
        fileCallback(filePath, directory, fileName);
      }
      else if (stats.isDirectory()) {
        arguments.callee(filePath, fileCallback);
      }
    }
};
