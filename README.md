# AwesomePD

A super-secret prototype in collaboration with [Paul Wicks](https://www.linkedin.com/in/paulwicks/) of [PatientsLikeMe](https://www.patientslikeme.com/).
Goal is to allow patients to see the cumulative effects of treatments taken in the course of a daily regimen.

## Installation

```
cd <project-dir>
pod install
```

## Using the app

When you add treatments to the timeline, you'll see a curve representing that treatment's effect over time.
If you add multiple treatments, you'll see a yellow line showing the combined effect.
Goal is to keep the combined effect within the high and low range.

**To add treatments to the timeline**

* Drag and drop a pill from the picker on the right to the chart to add it.
* Slide the pill left and right to move on the timeline.
* To delete a pill on the timeline, long press it.  When it starts to wiggle, click again to delete.

**To change what the treatment curve looks like for a pill**

* Double click a pill, either on the timeline or in the picker.
* In the curve editor that pops up, drag the individual points around to re-shape the curve.
* Click on the editor to add a new point.
* Double-click a point to remove it.

**To modify the high and low range limits**

* Just drag the limit bars up or down.

## Thanks to

* [Ramshandilya's Bezier project](https://github.com/Ramshandilya/Bezier) demonstrating smooth-line-interpolation
with Cubic Bezier curves in Swift. (I have a [pull request](https://github.com/Ramshandilya/Bezier/pull/2) to update it to Swift 3.0 -- [[full source]](https://github.com/jcole/Bezier))
* Erica Sadun blog post on [calculating points along a Bezier curve](http://ericasadun.com/2013/03/25/calculating-bezier-points/).
