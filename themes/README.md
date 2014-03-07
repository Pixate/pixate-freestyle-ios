#Freestyle Themes

Pixate Freestyle allows you to style an entire iOS app with CSS, making an app themeable by applying different collections of CSS classes. Changing the theme of an app is as simple as switching out the CSS file used by the Pixate Freestyle framework.

![My image](http://pixate.github.io/pixate-freestyle-ios/themes/assets/pixate_blue_form_styles.png)
![My image](http://pixate.github.io/pixate-freestyle-ios/themes/assets/pixate_blue_typography.png)


## Using themes

If you haven't already, [add Pixate Freestyle to your app](https://github.com/Pixate/pixate-freestyle-ios).

Themes consist of various classes that work with the Pixate Freestyle framework to style controls and views in your app. All themes have a default.css file which contains all of the styles included with the theme. A theme can also include a set of Sass files that compile into the default.css file. See more below in the  'Compiling Sass' section.

### Grab a theme

You can browse a directory of existing themes in the [Pixate Freestyle repo](https://github.com/Pixate/pixate-freestyle-ios/tree/master/themes). 

### Add the theme to your app

If the theme contains [Sass](http://sass-lang.com) files and you want to use them to make customization easier, add the files to your project. You will need to set up the Sass precompiler - see the 'Compiling Sass' section below. This option makes it a lot easier to customize the styles, since it's completely modular. 

Otherwise, add the default.css file from the theme to your project. This contains all of the styles in the theme. 

Once the CSS or SCSS files are added, you can apply the contained classes to any relevant view or control by adding a `styleClass` runtime attribute in Interface Builder to the view or control, or importing `Pixate/Pixate.h` in your view controller and setting the `styleClass` property (e.g. `myButton.styleClass = @"button small";`. The Pixate [Getting Started](http://www.pixate.com/docs/framework/ios/latest/getting-started/#using_css) guide has more details on setting classes.


## Contributing themes

New theme contributions are welcome. We are working on a theme guideline and a base theme that everyone can clone and modify, but in the meantime, please use the control and class names included in the [pixate-blue theme](https://github.com/Pixate/pixate-freestyle-ios/tree/master/themes/pixate-blue). Your theme can style any set of controls or views, and must include the following:

* A default.css file containing every style in your theme
* A README.md file documenting the views and controls your theme styles, and ideally a screenshot of the theme in action
* Optional: Sass files that properly compile into a default.css file

To contribute your theme:

1. [Fork](http://help.github.com/fork-a-repo/) Pixate Freestyle, clone your fork,
   and configure the remotes:

   ```bash
   # Clone your fork of the repo into the current directory
   git clone https://github.com/<your-username>/pixate-freestyle-ios.git
   # Navigate to the newly cloned directory
   cd pixate-freestyle-ios
   # Assign the original repo to a remote called "upstream"
   git remote add upstream https://github.com/Pixate/pixate-freestyle-ios
   ```

2. If you cloned a while ago, get the latest changes from upstream:

   ```bash
   git checkout master
   git pull upstream master
   ```

3. Commit your new theme in the /themes directory

4. Push your topic branch up to your fork:

   ```bash
   git push origin master
   ```

5. [Open a Pull Request](https://help.github.com/articles/using-pull-requests/)
    with a clear title and description against the `master` branch.

**IMPORTANT**: By submitting a theme, you agree to allow it to be
licensed under the terms of the [Apache 2.0 License](https://github.com/Pixate/pixate-freestyle-ios/blob/master/LICENSE).
        

## Compiling Sass 

A theme may include several [Sass](http://sass-lang.com) files that, once compiled, generate the CSS that will be used by Pixate Freestyle. Sass allows themes to be modular. You can modify variables to theme the default styles, or edit any part of the Sass to your heart's content.

You can simply grab the compiled CSS file from a theme and add it to your project (see [Getting Started](/getting-started/index.html)), or you can follow these simple steps to compile the .scss files. Once you've installed Freestyle and added a theme's Sass files to your application, do the following:

* Install [Sass](http://sass-lang.com/install) - this requires Ruby, which you should already have if you're running OS X.
* If you already added the Freestyle default.css file to your project, remove it (it will be replaced by the compiled Sass files).
* Add all of the files in Freestyle/scss to your project in Xcode.
* In XCode, click on your project in the Project Navigator.  
* Click on the `Build Phases` tab.
* From the top menu under `Editor`, select `Add Build Phase`, then `Add Run Script Build Phase`.
* If you're using RVM, In the new Run Script field enter: 

```
source /Users/${USER}/.rvm/environments/default
${GEM_HOME}/bin/sass ${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/default.scss ${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/default.css
```

* If you're using rbenv, you should enter this instead: 

```
/Users/${USER}/.rbenv/shims/sass ${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/default.scss ${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/default.css
```

* Do not put anything under `Input Files` or `Output Files`

Now, when you build your project, the Sass files should be compiled into a default.css file that will be used by the Pixate Framework. 


