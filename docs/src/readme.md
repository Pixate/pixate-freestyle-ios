Documentation Readme
====================

## Introduction

This houses documentation and instructions for Pixate Freestyle. Pages are rendered as part of our static website's build process. We use [Jade](http://jade-lang.com) for templating and [GitHub Flavored Markdown](http://github.github.com/github-flavored-markdown/) for the majority of our content via Jade filters.

All submissions are welcome. To submit a change, fork this repo, commit your changes, and send us a [pull request](https://help.github.com/articles/using-pull-requests).

## Building the Docs

Running `grunt` in this directory builds the Index page, themes, and styling reference. The dev reference is built using the appledocs package, via a script in the `/scripts` directory.

To build all the docs at once, run `/scripts/build_documentation`.