# Getting Started with Pixate Engine for iOS

Thank you for using Pixate Engine for iOS.  This guide will help you get started.

If you have already created a project using Pixate 1.0, this [transition guide](http://cdn.pixate.com/docs/engine/ios/2.0RC1/1-2-transition-guide.html) will help you migrate your project to Pixate 2.0.

**CocoaPods Users:** Skip the installation instructions and start [here](#license).

## Table of Contents

* [Introduction](#introduction)
* [Installing Pixate Engine for iOS](#installation)
* [Adding the Pixate Engine to a New Project](#new_project)
* [Adding the Pixate Engine to an Existing Project](#existing_project)
	* [Adding the CoreText and QuartzCore Libraries](#linked-libraries)
	* [Enabling Pixate and Setting Your Pixate License](#license)
* [Getting Started Video](#getting_started_video)
* [Install the Playground App](#install_playground)
* [Sample Applications](#sample_applications)
* [Real-time App Styling](#real-time_app_styling)
* [Styling Using Code](#code_only)
* [Pixate Resources](#resources)

## <a id="introduction"></a>Introduction

Long gone are the days of tedious image slicing and burdensome revisions just to create custom mobile interfaces. With Pixate,
designers and developers alike can conceive, implement, and modify
native mobile interfaces effortlessly and in real time through the
familiar CSS syntax.

Pixate styles all native iOS controls using standard CSS.  To ensure
maximum performance and compatibility, Pixate does not require
subclassing the native controls or using a custom set of
components. See the [Pixate Engine for iOS Styling Reference](<Pixate Engine for iOS Styling Reference.html>)
for a complete list of controls and properties.

  To experience the power of Pixate you'll need to use Xcode 4.5 or
later, and iOS 5.1 or 6.

## <a id="installation"></a>Installing Pixate Engine for iOS

If you haven't already, [download](http://download.pixate.com) Pixate. You'll also need a [license key](http://download.pixate.com/key). Don't worry. **It's free!**

After opening the installer, simply copy the Pixate folder to a convenient location. The
Pixate folder contains the Pixate framework, a link to the online
documentation center, and sample applications.

Next we'll add Pixate to a new project or you can jump to the
[next section](#existing_project) to start with an existing project.

## <a id="new_project"></a>Adding the Pixate Engine to a New Project

Let's create a simple iPhone project using the Pixate framework. In
XCode, select New->Project... For this demo, we're using a "Single
View Application".

![Single View Application](images/single_view_application.png)

Fill in the details for the product name, company identifier, and
class prefix. Note that although Pixate runs on all iOS devices, this
article is generating an iPhone app, so select that for the device
family. Finally, make sure "Use Automatic Reference Counting" is
checked in the bottom section. Click "Next" and save your project
wherever you would like.

![Project Details](images/project_details.png)

## <a id="existing_project"></a>Adding the Pixate Engine to an Existing Project

Select the xib file for your project.  Access the Utilities area and
ensure that the Autolayout setting in the Interface Builder Document
panel is not checked.  Pixate supports Autolayout of controls but we
won't use it for this project.   Also, make sure that Automatic
Reference Counting is enabled for the project.

![Autolayout setting](images/autolayout.png)

Now we need to include references to the Pixate framework. Expand the
project folder in Xcode's Project Navigator. Locate the
`Pixate.framework` in the Pixate Framework folder and drag it to
the "Frameworks" group.

![Adding The Framework](images/frameworks.png)

When prompted, make sure your project target is selected in the 'Add
to targets' section. Click "Finish".

![Adding Frameworks](images/add_frameworks.png)

Pixate defines custom Objective-C categories. This requires
configuration of an additional linker flag in order for the categories
to be loaded at runtime. In the Project Navigator, click on your
project folder. Switch to the "Build Settings" tab (be sure to also
click on the 'All' selection next to the 'Basic' selection.) Now type
"other linker" in the filter text box. Click the right column of the
"Other Linker Flags" (or `OTHER_LDFLAGS`) and add `-ObjC`.

![Set Linker Flag](images/set_linker_flags.png)

## <a id="linked-libraries"></a> Adding the CoreText and QuartzCore Libraries

Before you use Pixate, a couple of Apple libraries need to be added to your project. These libraries, **CoreText.framework** and **QuartzCore.framework**, can be added by clicking on the project icon in the source list, and scrolling down to the **Linked Frameworks and Libraries** section.

This can be found on **Summary** tab in Xcode 4.

![Xcode 4 Summary Tab](images/LinkedFrameworks-1.png)

…and in the **General** tab in Xcode 5.

![Xcode 5 General Tab](images/LinkedFrameworks-1-Xcode5.png)

Click the **+** button. Search for "coretext", click on **CoreText.framework**, and click the **Add** button.

![Adding CoreText.framework](images/LinkedFrameworks-2.png)

Now do the same thing for **QuartzCore.framework**.

![Adding QuartzCore.framework](images/LinkedFrameworks-3.png)

You should now see both frameworks added to the **Linked Frameworks and Libraries** list.

![You win at adding frameworks!](images/LinkedFrameworks-5.png)

## <a id="license"></a>Enabling Pixate and Setting Your Pixate License

To enable the Pixate Engine in your app, you'll need to set the styleMode of your app's window and call the Pixate initializer, passing it your license key and username.

Let's start with styleMode. Add an **#import** line at the top of your AppDelegate file:

	#import <Pixate/Pixate.h>

Then, right before **[self.window makeKeyAndVisible];**, add the following call:

	self.window.styleMode = PXStylingNormal;

It should look something like this:

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        ...your other code here...

        self.window.styleMode = PXStylingNormal;

        [self.window makeKeyAndVisible];
        
        return YES;
    }

Note that if you are using storyboards, you will not have the makeKeyAndVisible method call. Simply place the styleMode call right before **return YES;**.

Next, let's add the Pixate call to **main.m**. Add this **import** line:

    #import <Pixate/Pixate.h>

Then add the Pixate call, within the **@autoreleasepool** block, adding your personal license key and username.

    [Pixate licenseKey:@"YOUR LICENSE KEY" forUser:@"YOUR USER NAME"];

The file should look like this:

    #import <UIKit/UIKit.h>
    #import <Pixate/Pixate.h>

    #import "AppDelegate.h"

    int main(int argc, char *argv[])
    {
        @autoreleasepool {        
            [Pixate licenseKey:@"YOUR LICENSE KEY" forUser:@"YOUR USER NAME"];
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }

That's all you need to do to enable styling in your project.

## Styling a Button

First, let's create a button.

Open the xib file in your Project Navigator. At the bottom of the
Utilities View, type "button" in the filter.

![Filter for Button](images/filter_for_button.png)

Drag a "Round Rect Button" into your view. You can double-click the
button to give it any label you'd like. We'll call ours "My Button".

![Button App](images/buttonApp.png)

With the new button selected, activate the Identity
Inspector in the Utilities View.

Now we need to give this button a `styleId` so that you can reference
it from your CSS. We'll add a Runtime Attribute. Click the small '+'
and add an entry with a key path of `styleId`, a type of `String`, and
a value of `button1`.

![Runtime Attribute](images/runtimeAttribute.png)

Now create a new file called **default.css** anywhere in your project
(e.g. in a *Resources* folder, perhaps) to hold your app's CSS.

In this default.css file, add the following:

	#button1 {
		background-color: yellow;
	}

Now run your application. Your button should now have a yellow
background!

![Button1](images/button1.png)

Let's add a few more lines to the CSS file...

	#button1 {
    	background-color: yellow;
    	border-width:     2px;
    	border-color:     black;
    	border-radius:    8px;
        border-style:     solid;
	}

And now run the app again. Now you have a nice black border and
rounded corners!

![Button2](images/button2.png)

You've just styled your first app using Pixate.  From here, try out
the Playground on your iPad to experiment some more, or just keep
changing the CSS and expand the styling of your app!

## <a id="getting_started_video"></a>Getting Started Video

There is also a short
Getting Started video on our
[YouTube channel](http://www.youtube.com/user/PixateInc). There are also a growing set of videos on our [Vimeo Channel](http://vimeopro.com/pixateinc/videos).

## <a id="install_playground"></a>Install The Playground App

The Playground app is an iPad app for experimenting with styling of
native components using Pixate. The app is free and can be installed
by visiting the
[Pixate Playground app](https://itunes.apple.com/us/app/pixate-playground/id578676382?ls=1&mt=8)
on the App Store.

The Playground source code is available at the [Pixate Playground](https://github.com/Pixate/Playground) project on GitHub

![Playground](images/playground.png)

After installing the Playground, you're ready to style with
Pixate. Try styling the buttons simply by editing the CSS. The buttons
will be styled as you change the CSS.  Click on *Button...* near the
upper right corner of the app to select other types of controls to
style.

## <a id="sample_applications"></a>Sample Applications


We've provided a few sample applications in the *Samples* folder for you to experiment with
using Pixate.  You will require a licensed copy of Pixate Engine to compile these samples. Simply add your license name and serial number to the `Samples/License.h` before compiling these apps.


* `PXCodeOnly` - demonstrates using Pixate with an app built without
  using Interface Builder.
* `PXShapeDemo` - uses Pixate's SVG capabilities to generate scalable
  graphical images

You can find the source code for our Playground app on the [Pixate Playground](https://github.com/Pixate/Playground) project on GitHub.

## <a id="code_only"></a>Styling Using Code

Setting **styleId**, **styleClass**, or **styleCSS** can be done in code rather than using Interface Builder. Doing so if very easy, just set those properties direclty on any UIView or derivative object. For example:

	myButton.styleId = @“myButtonId”;

**styleClass** can be set directly this way, too:

	myButton1.styleClass = @“myButtons”;
	myButton2.styleClass = @“myButtons”;

Finally, you can even inline CSS directly in code:

	myButton.styleCSS = @“background-image: linear-gradient(white, black);”;

See the [API documentation](http://cdn.pixate.com/docs/engine/ios/latest/Pixate%20Engine%20for%20iOS%20Developer%20Reference.html) for more code-specific usage.

## <a id="real-time_app_styling"></a>Real-time App Styling

Wouldn't it be great while developing your app to be able to
re-style the app without needing to rebuild and redeploy it to the
simulator?  Visit our video on [Pixate Real Time CSS]
(http://www.youtube.com/watch?v=rjNrNIyEL_c&feature=plcp) to learn how
to configure your app to make use of this feature.

## <a id="resources"></a>Pixate Resources

The [Document Center](<http://www.pixate.com/documentation.html>) contains
the reference guides and how-to articles.

Keep up to date on the latest Pixate news, tips, and techniques at our
[Pixate blog](http://www.pixate.com/blog/).

You can sign-up on our [mailing list](http://pixatesurvey.herokuapp.com/) to be notified of new releases and Pixate news.

Thank you for trying Pixate.  If you have any questions or
suggestions, visit our support site at <http://www.pixate.com/support>.

------
<div style="font-size:10px">Last updated {DOC_GENERATED_DATESTAMP}</div>
