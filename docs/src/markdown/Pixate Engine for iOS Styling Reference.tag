# Pixate Engine for iOS Styling Reference

The Pixate Engine for iOS Styling Reference provides the details of the Pixate Engine from a designer's perspective. It summarizes the Pixate Engine's CSS3 support, and the style-able iOS native controls and their properties.

## Table of Contents

* [App Styling with Pixate Engine for iOS](#styling_with_pixate)
  * [Application Structure](#app_structure)
  * [Specificity](#specificity)
  * [CSS Media Queries](#media)
  * [Inline CSS](#inline_css)
  * [Importing Style Sheets](#imports)
  * [Media Assets](#assets)
  * [Runtime Configuration](#configuration)
* [CSS Selectors](#selectors)
    * [Simple Selectors](#simple_selectors)
    * [Attribute Selectors](#attribute_selectors)
    * [Pseudo-Classes](#pseudo_classes)
    * [Combinators](#combinators)
* [iOS Native Controls](#controls)
${toc.tmp}
* [Values](#values)
  * [Angle](#angle)
  * [Blend Modes](#blend_modes)
  * [Color](#color)
  * [Inset](#inset)
  * [Length](#length)
  * [Number](#number)
  * [Padding](#padding)
  * [Paint](#paint)
  * [Percentage](#percentage)
  * [Shadow](#shadow)
  * [Shape](#shape)
  * [String](#string)
  * [Size](#size)
  * [Transform](#transform)
  * [URL](#url)

<a id="styling_with_pixate"></a>App Styling with Pixate Engine for iOS
===

Pixate styles native iOS controls using CSS. The runtime is built on a scalable vector graphics engine, a standards-based CSS styling language, and a lightweight library for interacting with iOS native controls.

Pixate has tailored the familiar CSS3 language for the styling needs of native mobile components. Pixate CSS is "full CSS" with the exception of not supporting pseudo-elements and a few minor differences noted in this document.


<a id="app_structure"></a>Application Structure
---

Let's begin with an overview of a Pixate-based application.  At application start-up, Pixate looks for your application's CSS in a file named `default.css`, which can be located anywhere within your project.  The default.css file can include other CSS files by using `@import`.

CSS rules are applied using a control's `element name`, `class`, `id` or other attributes.  This information is represented at runtime by properties on Objective-C objects.

The `element name` is determined by the type of control.  For example, all UIButton controls have the `button` element name.  The control descriptions (see [Native iOS Controls](#controls)) lists the element name for each iOS control.

`class` and `id` are determined by the `styleClass` and `styleId` properties respectively of individual control instances. By convention, `styleClass` is shared by all controls with a related function or layout in the application, perhaps members within the same view.  `styleId` is expected to be unique across the application.  These conventions are not enforced by the Pixate Engine, and setting of these properties is not required unless you want to select controls using these properties.  These properties are typically set by the application developer.

<a id="inline_css"></a>Inline CSS
---
Application developers can style a specific control by setting the control's `styleCSS` property. This property is analogous to the style property of web CSS.

<a id="specificity"></a>Specificity
---
CSS Specificity determines which rules apply to controls.  Pixate follows standard CSS specificity rules.

Tip: Specificity is not simple and is usually the reason why your CSS-rules don't apply to some controls in the way you think they should.  Some excellent Specificity tutorials are available, including: [CSS Specificity: Things You Should Know](http://coding.smashingmagazine.com/2007/07/27/css-specificity-things-you-should-know/).


<a id="media"></a>CSS Media Queries
---

`@media` rules use CSS media queries to conditionally apply styles for different devices, screen
resolutions, and orientations.

The following media expressions are allowed:

* orientation: portrait | landscape
* device: ipad | iphone | ipad-mini
* device-width: \<number> | \<length>
* min-device-width: \<number> | \<length>
* max-device-width: \<number> | \<length>
* device-height: \<number> | \<length>
* min-device-height: \<number> | \<length>
* max-device-height: \<number> | \<length>
* scale: \<number>
* min-scale: \<number>
* max-scale: \<number>

Media types (e.g., 'print') are not supported.  Use 'and' to join multiple media expressions.

Below are example uses of the `@media` rule:

    /* Rule sets apply only when the device is in portrait orientation */
    @media (orientation:portrait) { }


    /* Rule sets apply if the device's height (ignores orientation)
       is at least 1000 pixels and if the device has a retina display. */
    @media (min-device-height:1000px) and (scale:2) { }


    /* Apply rules to iPad Mini in landscape mode. */
    @media (orientation:landscape) and (device:ipad-mini) { }

iPod and iPhone devices appear the same and are both targeted using device:iphone.
The iPad-Mini form factor is not supported in the simulator so it appears as an
iPad in the simulator.

Finally, note that CSS does not support `@import` statements within `@media` rules.

<a id="imports"></a>Importing Style Sheets
---

The `@import` rule allows importing style rules from other style
sheets.  The `@import` statement must be followed by a URL that
references a file within the application bundle or the device's Documents folder.  The following
statements are equivalent.

    @import url("style.css")

    @import "style.css"

Note that the `@import` does not support the CSS3 `@media` rule for specifying conditional style sheets or
alternative style sheets. Also `@import` is not supported within an `@media` statement.  This
restriction is silently enforced.


<a id="assets"></a>Media Assets
---

Media assets are accessed using the <a href="#url">url function</a> and must be contained within the Application's bundle or on the device filesystem.
Resources in the application bundle can be accessed using bundle://, files on the device are acessessed using file://,  and resources in the device documents
folder can be accessed using documents://.  If no protocol is specified, the resources will be
searched for first in the documents folder then in the resource bundle.

    /* search in documents folder and application bundle for resource */
    background-image:    url(star.svg);

    /* search for resource in a subfolder of Documents */
    background-image:    url(documents://myResources/star.svg);

    /* search for resource in a subfolder of  */
    background-image:    url(file://images/star.svg);

    /* search for resource in application bundle */
    background-image:    url(bundle://star.svg);

<a id="configuration"></a>Runtime Configuration
---

The Pixate engine allows you to customize some of its behavior, using CSS and a custom configuration element. You can access the configuration element by referencing it with the `pixate-config` element name. For example:

    pixate-config {}

The configuration element recognizes the following properties:

- parse-error-destination
- cache-styles
- image-cache-count
- image-cache-size

**parse-error-destination** recognizes the values `none` and `console`. Setting it to `console` displays any parse errors in your project's CSS in the XCode console during debugging. The default value is `none`.

**cache-styles** is used to toggle caching and to set limits for those caches. This property accepts a comma-delimited list of the following values: `auto`, `none`, `all`, `minimize-styling`, and `cache-images`. Values are processed in order and are accumulated. `auto` is the same as `minimize-styling, cache-images`. `minimize-styling` tries to prevent styling of an element if its styling has not changed. `cache-images` caches images generated during styling to avoid unnecessary rendering on future stylings and to generally increase styling speeds. The default (and recommended) value is `auto`.

**image-cache-count** determines how many images we be retained in the image cache, assuming it has been turned on with `cache-styles`. If this is set to `0`, then there will be no upper limit to how many images live in the cache. The default value is `10`.

**image-cache-size** determines how many bytes of image data are retained in the image cache. A value of `0` indicates that there is no upper limit to how many bytes can live in the cache. Note that `image-cache-count` will still be honored. The default value is `0`.

Below a short example that sends parse errors to the console, sets up default cache settings, and bumps the image cache count to 100 images.

    pixate-config {
        parse-error-destination: console;
        cache-styles: auto;
        image-cache-count: 100;
    }

## <a id="selectors"></a>Selectors

Selectors are used to designate to which controls a given rule set applies. Below you will find a list of selectors and combinators supported by the Pixate Engine. Note that each entry is a link to its associated section in the CSS3 specification. Simply click the entry to find detailed information about the given selector or combinator.

### <a id="simple_selectors"></a>Simple Selectors

Simple selectors allow for the selection of controls by `name`,
`class`, and `id`. A selector may include further restrictions on a selected element via attribute expressions; the Pixate Engine does not currently support those. Below is a list of simple selectors supported in the Pixate Engine.

- [element type selector](http://www.w3.org/TR/css3-selectors/#type-selectors) - Select a control by element name
- [universal selector](http://www.w3.org/TR/css3-selectors/#universal-selector) - Select any control
- [class selector](http://www.w3.org/TR/css3-selectors/#class-html) - Select a control by class name
- [id selector](http://www.w3.org/TR/css3-selectors/#id-selectors) - Select a control by ID

Below is a sample of each of the simple selectors.

    /* element type selector */
    button {}

    /* universal selector */
    * {}

    /* class selector */
    .my-class {}

    /* id selector */
    #my-id {}

See the [Cascading Style Sheets Overview](#sheets) section to learn how to specify the the `id` and `class` elements for a control.

NOTE: Pseudo-elements will parse but they are not implemented.

### <a id="attribute_selectors"></a>Attribute Selectors

Attribute selectors allow for controls to be selected based on the content of their attributes. Objective-c classes do not have attributes, per se, but these can be thought of as objective-c properties, in simple cases. Internally, the Pixate Engine will use Key-value Coding (KVC) to look up a property name. If that lookup is successful, then one of the following tests is performed, returning true only if the match is successful.

- [Attribute Presence](http://www.w3.org/TR/selectors/#attribute-representation) - Select a control that has the specified attribute
- [Equals](http://www.w3.org/TR/selectors/#attribute-representation) - Select a control that has an attribute equal to a specific value
- [List Item Equals](http://www.w3.org/TR/selectors/#attribute-representation) - Select a control that has an attribute with an item in a whitespace-delimited list equal to a specific value
- [Equal with Optional Hyphen](http://www.w3.org/TR/selectors/#attribute-representation) - Select a control that has an attribute  equal to a specific value or that is prefixed by the value followed by a hyphen
- [Starts With](http://www.w3.org/TR/selectors/#attribute-substrings) - Select a control that has an attribute starting with a specific value
- [Ends With](http://www.w3.org/TR/selectors/#attribute-substrings) - Select a control that has an attribute ending with a specific value
- [Contains](http://www.w3.org/TR/selectors/#attribute-substrings) - Select a control that has an attribute containing a specific value

### <a id="pseudo_classes"></a>Pseudo-classes

Many of the controls in UIKit allow settings to be associated with specific states: `normal`, `highlighted`, `disabled`, etc. The Pixate Engine uses pseudo-classes to indicate to which state a given rule set should apply.

Below is a sample of some pseudo-classes in use.

    /* normal button state */
    button:normal {}

    /* highlighted button state */
    button:highlighted {}

Pseudo-classes representing control states are currently limited to the last selector in a selector sequence.

Pseudo-classes are also used to match controls that meet a certain criteria. For example, it is possible to indicate that a control can match only if it is the first child of its parent, or the last child, etc. The Pixate Engine supports the following pseudo-classes in this category:

- [:root](http://www.w3.org/TR/selectors/#root-pseudo) - Select a control that is the root of a view and has no parent
- [:first-child](http://www.w3.org/TR/selectors/#first-child-pseudo) - Select a control that is the first child of its parent
- [:last-child](http://www.w3.org/TR/selectors/#last-child-pseudo) - Select a control that is the last child of its parent
- [:first-of-type](http://www.w3.org/TR/selectors/#first-of-type-pseudo) - Select a control that is the first child of its type
- [:last-of-type](http://www.w3.org/TR/selectors/#last-of-type-pseudo) - Select a control that is the last child of its type
- [:only-child](http://www.w3.org/TR/selectors/#only-child-pseudo) - Select a control that is the only child of its parent
- [:only-of-type](http://www.w3.org/TR/selectors/#only-of-type-pseudo) - Select a control that is the only child of its type
- [:empty](http://www.w3.org/TR/selectors/#empty-pseudo) - Select a control that does not have any children
- [:nth-child()](http://www.w3.org/TR/selectors/#nth-child-pseudo) - Select the nth child based on the specified pattern
- [:nth-last-child()](http://www.w3.org/TR/selectors/#nth-last-child-pseudo) - Select the nth child from the end based on the specified pattern
- [:nth-of-type()](http://www.w3.org/TR/selectors/#nth-of-type-pseudo) -Select the nth child of its type based on the specified pattern
- [:nth-last-of-type()](http://www.w3.org/TR/selectors/#nth-last-of-type-pseudo) - Select the nth child of its type from the end based on the specified pattern

### <a id="combinators"></a>Combinators

Combinators allow the expression of complex relationships between controls. A combinator combines any combination of simple selectors and other combinators. Each combinator represents a tree relationship that must be met to select a target control.

- [Descendant combinator](http://www.w3.org/TR/css3-selectors/#descendant-combinators) - Select a control that descends from another control
- [Child combinator](http://www.w3.org/TR/css3-selectors/#child-combinators) - Select a control that is a child of another control
- [Adjacent sibling combinator](http://www.w3.org/TR/css3-selectors/#adjacent-sibling-combinators) - Select a control that comes immediately after another control
- [General sibling combinator](http://www.w3.org/TR/css3-selectors/#general-sibling-combinators) - Select a control that comes after another control

Below is a sample of each of these combinators.

    /* descendant combinator */
    view button {}

    /* child combinator */
    view > label {}

    /* adjacent sibling combinator */
    button + label

    /* general sibling combinator */
    button ~ label

## <a id="controls"></a>Native iOS Controls

Below is a list of controls that are style-able using the Pixate
Engine. Each section lists the control, the control's element names, any children provided by the control, any pseudo-class states, the set of properties that can be applied to the control, and the values supported by each property.

In order to select a control by type, a CSS selector uses a type name selector. The Pixate Engine maps controls to one or more type/element names for this purpose.

Some aspects of UIKit controls are not directly accessible or do not map to UIViews. For example, a `UISlider` is composed of a `min-track`, a `max-track`, and a `thumb`. The Pixate Engine exposes these as children of the parent control. These "virtual" children are included within the control listing that contains them.

Some controls have different visual states. For example, a `UIButton` has a "normal" and "highlighted" state, as well as others. Each state allows for differing styles which take effect when the control is in that particular state. Pixate allows you to use pseudo-classes to indicate to which state the given rule set applies.

Values are referenced by type or string values. Alternate selections for a single value type are represented using a pipe symbol, '|', between each value type. Types are represented within angle brackets. Their definition can be found later in this document in the [Values](#values) section. String values are the literal text as they appear in this document.

${controls.tmp}

## <a id="values"></a>Values

Below is a list of value types supported by the Pixate Engine.

### <a id="angle"></a>Angle

An angle is a number followed by one of the following units: deg, rad, grad. Note that there must be no whitespace between the number and its unit. Zero values face horizontally to the right and then rotate counter-clockwise as the value increases.

### <a id="blend_modes"></a>Blend Modes

Below is a list of blend modes as defined by iOS. For a complete description of each mode, visit the following URL:

    http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CGContext/Reference/reference.html#//apple_ref/doc/c_ref/CGBlendMode

- clear
- color
- color-burn
- color-dodge
- copy
- darken
- destination-atop
- destination-in
- destination-out
- destination-over
- difference
- exclusion
- hard-light
- hue
- lighten
- luminosity
- multiply
- normal
- overlay
- plus-darker
- plus-lighter
- saturation
- screen
- soft-light
- source-atop
- source-in
- source-out
- xor

### <a id="color"></a>Color

A color is defined as a 3- or 6-digit hexadecimal number, as an SVG named color, or using any of the following color functions: rgb, rgba, hsl, hsla, hsb, or hsba. When using a hexadecimal number, each digit in a 3-digit hex number and each pair of digits in a 6-digit hex number correspond to an rgb color. The digits define each channel in order: red, green, then blue. For a list of named colors and their values, see [SVG named colors](http://www.w3.org/TR/css3-color/#svg-color).

    color               ::= <named-color>
                         |  <hex-color>
                         |  <rgb-color>
                         |  <hsl-color>
                         |  <hsb-color>

    named-color         ::= // See link above for names and values.

    hex-color           ::= #<hex-digit>{3} |  #<hex-digit>{6}

    rgb-color   ::= rgb(<byte-or-percent> [, <byte-or-percent>]{2}])
                 |  rgba(<byte-or-percent>
                         [, <byte-or-percent>]{2}, <unit-or-percent>])
                 |  rgba(<named-color>, <unit-or-percent>)
                 |  rgba(<hex-color>, <unit-or-percent>)

    hsl-color   ::= hsl(<angle-or-percent>, <byte-or-percent>,
                        <byte-or-percent>)
                 |  hsla(<angle-or-percent>, <byte-or-percent>,
                         <byte-or-percent>, <unit-or-percent>)

    hsb-color   ::= hsb(<angle-or-percent>, <byte-or-percent>,
                        <byte-or-percent>)
                 |  hsba(<angle-or-percent>, <byte-or-percent>,
                         <byte-or-percent>, <unit-or-percent>)

    hex-digit   ::= 'a' - 'f' | 'A' - 'F' | '0' - '9'

    byte-or-percentage  ::= 0 - 255 | <percentage>

    unit-or-percentage  ::= 0.0 - 1.0 | <percentage>

    angle-or-percentage ::= <radian> | <gradian> | <degree>

    percentage  ::= <number>%

    radian      ::= <number>rad

    gradian     ::= <number>grad

    degree      ::= <number>deg

    number      ::= // See http://www.w3.org/TR/css3-values/#numbers

### <a id="inset"></a>Inset

Insets are used to specify offsets for end-caps. This allows images to be resized while preserving the size of certain parts of the content. This is useful for button images, for example. If a single value is specified, it is used for top, right, bottom, and left insets. If two values are specified, the first number is used for the top and  bottom insets, and the second number is used for the right and left insets. If three values are specified, the first numbers is used for the top inset, the second number is used for the right and left insets, and the third number is used for bottom inset. If four values are specified, they indicate the top, right, bottom, and left
values, in that order.

    <inset>       ::= <inset-value> [,? <inset-value>]{3}
    <inset-value> ::= <number> | <length>

### <a id="length"></a>Length

A length is a number followed by one of the following units: `px`, `cm`, `mm`, `in`, `pt`, `pc`, `dpx`. Note that there must be no whitespace between the number and its unit.


Pixate provides the device pixel unit, `dpx`, as an extension.  This could be used, for example, to generate the thinnest possible line on a given device.

### <a id="number"></a>Number

A number is an integer or floating point value. A number may
optionally start with a minus sign, '-', or a plus sign, '+'. For an integer, the first digit must be in the range of 1 to 9, inclusive. Zero or more digits may follow. A floating point number starts with zero or more digits followed by a period, '.', followed by one or more digits. This can be summarized with the following regular expression:


    [-+]?([0-9]*\.[0-9]+|[0-9]+)

### <a id="padding"></a>Padding

Padding is used to create empty space within the border of a content of a region. If a single value is specified, it is used for `top`, `right`, `bottom`, and `left` `padding`. If two values are specified, the first number is used for the `top` and `bottom` padding, and the second number is used for the `right` and `left` padding. If three values are specified, the first number is used for the `top` padding, the second number is used for the `right` and `left` padding, and the third number is used for `bottom` padding. If four values are specified, they indicate the `top`, `right`, `bottom`, and `left` values, in that order.

    <padding>       ::= <padding-value> [,? <padding-value>]{3}
    <padding-value> ::= <number> | <length>


### <a id="paint"></a>Paint

Paints are used to specify how geometry is filled and how a geometry's stroke is filled. A paint may be a solid color or a linear gradient. Paints include an optional blending mode which defaults to 'normal' when not specified. More than one paint may be applied to geometry using a comma-delimited list of paints.

    paints              ::= <paint> [, <paint>]*

    paint               ::= [<color> | <linear-gradient> | <radial-gradient>] <blend-mode>?

    linear-gradient     ::= linear-gradient([<gradient-angle> ,]? <color> [, <color>]*)
                         |  linear-gradient([<gradient-angle> ,]? <color> <percentage>
                                        [, <color> <percentage>]*)
    gradient-angle      ::= <angle> | <gradient-direction>
    gradient-direction  ::= top | top left | left top | top right | right top | right
                         |  bottom | bottom right | right bottom | bottom left | left bottom | left

    radial-gradient     ::= radial-gradient(<color> [, <color>]*)
                         |  radial-gradient(<color> <percentage> [, <color> <percentage>]*)

NOTE: Pixate's CSS implementation does not support the full radial gradient syntax.

### <a id="percentage"></a>Percentage

A percentage is a number followed by a percent sign, `%`. Note that there must be no whitespace between the number and the percent sign.

### <a id="shadow"></a>Shadow

A shadow is to define inner and outer shadows in box-shadow properties. A shadow may be offset in any direction, and may include a blur amount and a color.

    <shadow>          ::= inset? <h-offset> <v-offset> [<blur-radius> <spread-distance>?]? <color>
    <h-offset>        ::= <length>
    <v-offset>        ::= <length>
    <blur-radius>     ::= <length>
    <spread-distance> ::= <length>

###<a id="shape"></a>Shape

A shape is used to define the contour of the background of a control. If the value is not specified, then the default value will be `rectangle`.

    <shape> ::= rectangle | ellipse | arrow-button-left | arrow-button-right

### <a id="size"></a>Size

A size consists of a width `<length>` followed by whitespace and a height `<length>`. If only one number is specified, then its value will be used for both the width and height values.

    <size>       ::= <size-value> [,? <size-value>]?
    <size-value> ::= <length> | <number>

### <a id="string"></a>String

A string is composed of a single-quote or double-quote, zero or more characters, ending with a matching quote type as was used to start the string. Carriage returns and newlines are not allowed in the content of the string.

    "This is a double-quoted string"
    'This is a single-quoted string'

NOTE: The current implementation successfully scans escape sequences, but they are not post-processed. For example, `abc\000A def` is a valid string, but the `\000A ` escape sequence will not be expanded to a newline.


### <a id="transform"></a>Transform

A transform value consists of one-or-more [SVG transforms](http://www.w3.org/TR/SVG/coords.html#TransformAttribute) separated by whitespace. Supported transforms are `translate`, `scale`, `rotate`, `skewX`, `skewY`, and `matrix`.

    <transforms> ::= <transform>+
    <transform>  ::= <translate> | <scale> | <rotate> | <skewX> | <skewY> | <matrix>
    <translate>  ::= translate(<number> [,? <number>]?)
    <scale>      ::= scale(<number> [,? <number>]?)
    <rotate>     ::= rotate(<number> [,? <number> ,? <number>]?)
    <skewX>      ::= skewX(<number>)
    <skewY>      ::= skewY(<number>)
    <matrix>     ::= matrix(number> [,? <number>]{5})

### <a id="url"></a>URL

URLs are specified using the `url` function. This function expects a single
`<string>` value. The quotes may be omitted. The referenced resource must be available within
your application bundle or the device's documentation folder.

Resources in the application bundle can be accessed using bundle://, files on the device are acessessed using file://,  and resources in the device documents
folder can be accessed using documents://.  If no protocol is specified, the resources will be
searched for first in the documents folder then in the resource bundle.

<!-- NOTE: The current implementation only supports access to resources in your applications bundle `[PT36500453]`. -->

------
<div style="font-size:10px">Last updated {DOC_GENERATED_DATESTAMP}</div>
