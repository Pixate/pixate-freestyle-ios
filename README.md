# Pixate Freestyle

Pixate Freestyle is a native iOS (and [Android](https://github.com/pixate/pixate-freestyle-android)) library that styles native controls with CSS. With Freestyle, you can replace many complicated lines of Objective-C with a few lines of CSS. This simplifies and centralizes your styling code, and [offers other benefits](http://www.freestyle.org/) as well.

## Getting Started

### Installation

There are several ways to download and install the Pixate Freestyle framework.

The easiest is to [download the installer](http://www.freestyle.org/downloads/freestyle/PixateFreestyle-2.1.4.pkg), which always contains the latest  version, and drag **PixateFreestyle.framework** into your Xcode project. Alternatively, you can download the framework file only (i.e. no samples) by going to the [releases section](https://github.com/Pixate/pixate-freestyle-ios/releases) of this repo.

*NOTE: The installer will place the files into your **Documents** folder in a folder named **PixateFreestyle***. 

 Once installed, add the following import to the top of your **main.m** file:

```
#import <PixateFreestyle/PixateFreestyle.h>
```

In the body of your main method, add the following line before the return:

```
[PixateFreestyle initializePixateFreestyle];
```

Your main method should look something like this:

```
int main(int argc, char *argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```

If you use [CocoaPods](http://cocoapods.org), install the Freestyle cocoapod by adding **PixateFreestyle** to your Podfile:

```
pod 'PixateFreestyle'
```

### RubyMotion, Xamarin, and Titanium

Modules are also available (with source code) for using Pixate Freestyle on iOS with:

* [RubyMotion](https://github.com/Pixate/RubyMotion-PixateFreestyle)
* [Xamarin](https://github.com/Pixate/Xamarin-PixateFreestyle)
* [Titanium](https://github.com/Pixate/Titanium-PixateFreestyle)

### Migrating from Pixate Framework

If you are migrating from the Pixate Framework, you’ll only need to make a few changes, namely updating your imports to use ‘PixateFreestyle’ and updating your initialization method in your main.m.

In terms of your ‘#import” lines, just update them to read as follows:

```
#import <PixateFreestyle/PixateFreestyle.h>
```

And like the Installation step above, just change your main.m to look like the following, you no longer need to use a license key or user name.

```
#import <PixateFreestyle/PixateFreestyle.h>

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [PixateFreestyle initializePixateFreestyle];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```

### Styling Apps with CSS

Pixate Freestyle allows you to add IDs, Class'es, and inline styles to your native components, and style them with CSS. Learn more about this [here](http://pixate.github.io/pixate-freestyle-ios/style-reference/index.html#app_structure).

For now, let’s make a simple app that styles a single button. Follow [this short video](http://player.vimeo.com/video/79832578) and then add the following CSS code to a new file, `default.css`, in your Xcode project.

    ```
    view {
      background-color: #ffffff
    }

    .btn-green {
      color            : #446620;
      background-color : linear-gradient(#87c44a, #b4da77);
      border-width     : 1px;
      border-color     : #84a254;
      border-style     : solid;
      border-radius    : 10px;
      font-size        : 13px;
    }
    ```

### Moving Faster with Themes

You can build the style of your app piece-by-piece using the method above. For even faster development, use a pre-built [Freestyle theme](http://pixate.github.io/pixate-freestyle-ios/themes). Themes have pre-built CSS and Sass that can be quickly customized to style an entire app. Learn more [here](http://pixate.github.io/pixate-freestyle-ios/themes).

## Mailing List & Twitter

Keep up with notifications and announcements by joining Pixate's [mailing list](http://pixatesurvey.herokuapp.com) and [follow us](http://twitter.com/PixateFreestyle) on Twitter.

## Docs

You can find the latest Pixate Freestyle documentation [here](http://pixate.github.io/pixate-freestyle-ios).

## Compiling Freestyle Source

To compile the Pixate Freestyle source outside of Xcode or your project, just clone the repo and go into the **scripts/** directory. From there, run the '**build_framework.sh**' script. It will compile the framework and create a "FAT" binary and place it in a **build/** folder at the root level of the repo.

## Contributing

Pixate welcomes contributions to our product. Just fork, make your changes, and submit a pull request. All contributors must sign a CLA (contributor license agreement).

To contribute on behalf of yourself, sign the individual CLA here:

 [http://www.freestyle.org/cla-individual.html](http://www.freestyle.org/cla-individual.html)

To contribute on behalf of your employer, sign the company CLA here:

 [http://www.freestyle.org/cla-company.html](http://www.freestyle.org/cla-company.html)

All contributions:

1. MUST be be licensed using the Apache License, Version 2.0
2. authors MAY retain copyright by adding their copyright notice to the appropriate flies

More information on the Apache License can be found here: [http://www.apache.org/foundation/license-faq.html](http://www.apache.org/foundation/license-faq.html)

## Support

Pixate offers various levels of free and paid support. Please visit our [support site](http://www.freestyle.org/support.html) for more details.

## License

Except as otherwise noted, Pixate Freestyle for iOS is licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.html).

