# AwesomePD

![Awesome PD demo](https://cloud.githubusercontent.com/assets/12082/23618209/9d873a76-025d-11e7-9b9d-245ae00c079c.gif)

A super-secret prototype in collaboration with [Paul Wicks](https://www.linkedin.com/in/paulwicks/) of [PatientsLikeMe](https://www.patientslikeme.com/).
Goal is to allow patients to see the cumulative effects of treatments taken in the course of a daily regimen.

## Installation

```
cd <project-dir>
pod install
```

Then open AwesomePD.xcworkspace.

## Using the app

Each treatment in the timeline has a curve showing its effect over time.
A yellow line shows the combined effect of all treatments.
Goal is to keep the combined effect within the high and low range.

**To add a treatment to the timeline**

* Drag and drop a pill from the picker on the right to the chart.
* Slide it left and right to move on the timeline.
* To delete a pill, long press it.  When it starts to wiggle, click again to delete.

**To edit a pill's treatment curve**

* Double click a pill, either on the timeline or in the picker.
* In the curve editor that pops up, drag the individual points around to re-shape the curve.
* Click anywhere on the editor to add a new point.
* Double-click a point to remove it.

**To modify the high and low range limits**

* Just drag the limit bars up or down.

## Thanks to

* [Ramshandilya's Bezier project](https://github.com/Ramshandilya/Bezier) demonstrating smooth-line-interpolation
with Cubic Bezier curves in Swift. (I have a [pull request](https://github.com/Ramshandilya/Bezier/pull/2) to update it to Swift 3.0 -- [[full source]](https://github.com/jcole/Bezier))
* Erica Sadun blog post on [calculating points along a Bezier curve](http://ericasadun.com/2013/03/25/calculating-bezier-points/).
