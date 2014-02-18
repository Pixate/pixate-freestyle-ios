# Pixate 1.0 to 2.0 Transition Guide
If you are upgrading your app from Pixate 1.0 to Pixate 2.0, you will need to change a few lines of code in order for your app to work correctly.

Don't worry, it'll only take a few minutes.

If you're using Pixate for the first time, skip this guide and check out [Getting Started](http://cdn.pixate.com/docs/engine/ios/2.0RC1/Getting%20Started.html) instead.

## Framework Setup
Three important changes have been made to setup:

1. `PXEngine.framework` is now called `Pixate.framework`. Change all import statements and calls to the Pixate framework to reflect this. Calls to PXEngine are **deprecated**.
2. `[Pixate initializeFrameworkWithKey: forUser:]` has been switched back to `[Pixate licenseKey: forUser:]`. This call should be placed in the `@appreleasepool` block in your main.m.
3. `CoreText.framework` and `QuartzCore.framework` must be added to your project. See the [Getting Started](http://cdn.pixate.com/docs/engine/ios/2.0RC1/Getting%20Started.html) guide for instructions on adding them.

## CSS Name Changes

Some of the style names have changed, mostly to adhere to CSS convention.

<table>
<colgroup>
<col style="text-align:left;"/>
<col style="text-align:left;"/>
</colgroup>

<thead>
<tr>
	<th style="text-align:left;">Old Name</th>
	<th style="text-align:left;">New Name</th>
</tr>
</thead>

<tbody>
<tr>
	<td style="text-align:left;">nav-buttons {}</td>
	<td style="text-align:left;">bar-button {}, back-bar-button {}</td>
</tr>
<tr>
	<td style="text-align:left;">font-align</td>
	<td style="text-align:left;">text-align</td>
</tr>
<tr>
	<td style="text-align:left;">color: none</td>
	<td style="text-align:left;">color: transparent</td>
</tr>
<tr>
	<td style="text-align:left;">background-top-inset</td>
	<td style="text-align:left;">background-inset-top</td>
</tr>
<tr>
	<td style="text-align:left;">background-right-inset</td>
	<td style="text-align:left;">background-inset-right</td>
</tr>
<tr>
	<td style="text-align:left;">background-bottom-inset</td>
	<td style="text-align:left;">background-inset-bottom</td>
</tr>
<tr>
	<td style="text-align:left;">background-left-inset</td>
	<td style="text-align:left;">background-inset-left</td>
</tr>
</tbody>
</table>

## Other CSS Changes

* Border-style is required when defining borders. Only `none` and `solid` are supported at this time.
* Linear gradient angles now correctly match the CSS specification. This includes the default angle when none is specified as well as explicit angle values.
* Using gradients with `background-color` is **deprecated**. Set gradient backgrounds using `background-image`.
* Multiple transforms in a transform property are now applied in the correct order.