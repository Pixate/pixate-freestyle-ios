module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-jade');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-clean');

  var buildPath = grunt.option('build-path') || '../../docs' ;

  var rootURL = grunt.option('root-url') || '' ;

  // Used by jade and validate-and-build-controls
  var controlsNavItems = [];
  var styleReferenceNavItems = null;
  var controlData = {};

  var configData = grunt.file.exists('config.json') ? grunt.file.readJSON('config.json') : null;

  var documentedValues = {
    angle:true,
    'blend-mode':true,
    color: true,
    inset:true,
    length:true,
    number:true,
    padding:true,
    paint:true,
    percentage:true,
    shadow:true,
    shape:true,
    string:true,
    size:true,
    transform:true,
    url:true
  };

  grunt.initConfig({
    jade: {
      compile: {
          options: {
            client: false,
            pretty: true,
            data: function(dest, src) {
              var filePath = src[0];
              var locals = {rootURL: rootURL}

              if (configData) {
                locals.config = configData;
              }

              // Build custom nav for style reference.
              if (filePath.indexOf('style-reference') !== -1) {
                locals.navItems = getStyleReferenceNav()

                if (filePath.indexOf('style-reference/controls') !== -1) {
                  key = getControlKey(filePath);
                  locals.controlData = controlData[key];
                }
              }

              else if (grunt.file.exists(getNavFilePath(filePath))) {
                locals.navItems = grunt.file.readJSON(getNavFilePath(filePath)).navItems;
              }

              //translate for relativeURLs
              if (rootURL === '') {
                locals.rootURL = getRelativeRoot(filePath);
              }

              return locals;
            }
          },
          files: [ {
            expand: true,
            cwd: 'docs_src/',
            src: '**/*.html.jade',
            dest: buildPath,
            ext: '.html'
          } ]
      }
    },
    sass: {
      main: {
        files: [{
          expand: true,
          cwd: 'web/sass/',
          ext: '.css',
          src: ['*.sass'], 
          dest: buildPath+'/css/'
        }]
      }
    },
    copy: {
      web: {
        files: [{
          expand: true,
          cwd: 'web/assets/',
          src: ['**/*'], 
          dest: buildPath
        }]
      },
      assets: {
        files: [{
          expand: true,
          cwd: 'docs_src',
          src: '**/assets/**/*',
          dest: buildPath
        }]
      }
    },
    clean: {
      build: {
        src: [buildPath+'/*']
      }
    }
  });

  grunt.registerTask('default', 'builds offline docs.', ['copy', 'validate-and-build-controls', 'jade', 'sass']);

  grunt.registerTask('validate-and-build-controls', 'Compares files in style-reference with JSON manifest, notes any inconsistencies.', function() {

    // Initialize variables.
    var controlsSpec = grunt.file.readJSON('specs/controls.json');
    var stubFiles = retrieveStubFiles();   

    // Do the work.
    var numMissingControls = matchControlsToStubsAndReturnNumMissing(controlsSpec, stubFiles);
    var numExtraStubs = getNumExtraStubs(stubFiles);

    // Write the logs.
    writeSummaryLogs(numMissingControls, numExtraStubs);
  });


  //
  // Helper Functions
  //

  var matchControlsToStubsAndReturnNumMissing = function (controlsSpec, stubFiles) {
    var numMissingControls = 0;

    for (var specName in controlsSpec) {
      var controlName = specName.replace(/^PX/,"").replace(/\+PXStyling/,"");
      var fileName =  getControlKey(controlName) + '.html.jade';

      formatProperties(controlsSpec[specName]);

      if (isControlChild(controlName)) {
        addChildToControlData(controlName, controlsSpec[specName]);
      }

      else if (stubFiles[fileName]) {
        addControlToNav(controlName);
        addControlToControlData(controlName, controlsSpec[specName])
        delete stubFiles[fileName];
      }

      else {
        grunt.log.error('Stub file not found: '+fileName);
        numMissingControls++;
      }
    }

    return numMissingControls;
  }

  var formatProperties = function (controlObject) {
    var newProps = [];
    
    for (var i in controlObject.properties) {
      newProps.push(makePropertyObject(i, controlObject.properties[i]));
    }

    controlObject.properties = newProps;
  }

  var makePropertyObject = function (propertyName, propertyInfo) {
    return {
      name: propertyName, 
      values: makeValuesArray(propertyInfo),
      comment: propertyInfo.comment
    };
  }

  var makeValuesArray = function (propertyInfo) {
    var retVal = [];
    var valueObj;
    var values = propertyInfo.syntax.replace(/<|>|\+|\s/g, "").split(/\|+/);
    for (var i = 0; i < values.length; i++) {
      valueObj = { name: values[i] };
      if (documentedValues[valueObj.name])
        valueObj.url = "/style-reference/values.html#"+values[i];
      retVal.push(valueObj);
    }

    return retVal;
  }

  var addControlToNav = function (controlName) {
    if (!isControlChild(controlName)) {
      var navItem = {url: '/style-reference/controls/' + getControlKey(controlName) + '.html', title: controlName};
      controlsNavItems.push(navItem);
    }
  };

  var addControlToControlData = function (controlName, controlObject) {
    var keyName = getControlKey(controlName);

    if (!controlData[keyName]) {
      controlData[keyName] = {children:[]};
    }

    controlData[keyName].definition = controlObject;
    controlData[keyName].name = controlName;
  };

  var addChildToControlData = function (controlName, controlObject) {
    var keyName = getControlKey(controlName);
    var baseControlName = keyName.replace(/\.(\w|-)*/,"");

    if (!controlData[baseControlName]) {
      controlData[baseControlName] = {children:[]};
    }

    controlData[baseControlName].children.push(controlObject);
  };

  var getControlKey = function (stubPathOrControlName) {
    var key = stubPathOrControlName;

    if (key.indexOf("/") !== -1)
      key = key.match(/\w*(?=.html.jade)/i);  
    else
      key = key.toLowerCase();

    return key;
  }

  var isControlChild = function (controlName) {
    return controlName.indexOf('.') !== -1;
  };

  var retrieveStubFiles = function () {
    var stubFiles = {};
    grunt.file.recurse(
      'docs_src/style-reference/controls',
      function callback(abspath, rootdir, subdir, filename) {
        stubFiles[filename] = true;
      }
    );

    return stubFiles;
  };

  var getNumExtraStubs = function (stubFiles) {
    var numExtraStubs = 0;

    for (var i in stubFiles) {
      if (i !== '.DS_Store') {
        grunt.log.error(i + ' was found but is not in the JSON manifest.');
        numExtraStubs++;
      }
    }

    return numExtraStubs;
  };

  var getNavFilePath = function (filePath) {
    var enclosingFolderPath = filePath.replace(/(\.|\w)*$/,"");
    return './' + enclosingFolderPath + '/nav.json';
  };

  var getRelativeRoot = function (filePath) {
    var root = '';
    var depth = filePath.split('/').length - 2;

    if (depth == 0) {
      root = './'
    }
    else {
      for (var i = 0 ; i < depth; i++) {
        root += '../';
      }
    }

    return root;
  };

  var getStyleReferenceNav = function () {
    if (!styleReferenceNavItems) {
      styleReferenceNavItems = grunt.file.readJSON('./docs_src/style-reference/nav.json').navItems;
      
      // We could search for the controls section in a loop, but this is faster, and will warn us if it breaks.
      if (styleReferenceNavItems[2].title == 'iOS Native Controls')
        styleReferenceNavItems[2].children = controlsNavItems;
      else
        throw new Error('The controls section of the nav is not where we thought it was.');
    }

    return styleReferenceNavItems;
  };

  var writeSummaryLogs = function (numMissingControls, numExtraStubs) {
    if (numMissingControls || numExtraStubs)
      grunt.log.write('\nERROR SUMMARY\n=============\n\n');

    if (numMissingControls)
      grunt.log.error(numMissingControls + ' controls are missing stubs.');

    if (numExtraStubs)
      grunt.log.error(numExtraStubs + ' extra stubs were found that are not in the JSON manifest.');
  }
};