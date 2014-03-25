# ADLivelyTableView - UITableView with style

ADLivelyTableView is a drop-in subclass of UITableView that lets you add custom animations to any UITableView.

It's rather simple to use :

*   Add ADLivelyTableView.h and ADLivelyTableView.m to your iOS project
*   Link against the QuartzCore framework if you don't already
*   Turn any UITableView you want to animate (or subclass thereof) into a subclass of ADLivelyTableView
*   Pick whichever animation you like, like this : ``livelyTableView.initialCellTransformBlock = ADLivelyTransformFan;``

You can also write your own initial transform block.
