# Periscope-VideoViewController
Video view controller with [Periscope](https://itunes.apple.com/us/app/periscope/id972909677?mt=8) fast rewind control.

Tutorial on how to create this component can be found [here](https://medium.com/@gontovnik/building-periscope-fast-rewind-control-for-ios-5cb6801db0fd#.go2t3gdec).

![](https://raw.githubusercontent.com/gontovnik/Periscope-VideoViewController/master/VideoViewController.gif)

## Requirements
* Xcode 7 or higher
* iOS 8.0 or higher (may work on previous versions, just did not test it)
* ARC
* Swift 3.0

## Demo

Open and run the **VideoViewControllerExample** project in Xcode to see this component in action.

## Example usage

``` swift
let videoURL = Bundle.main.url(forResource: "exampleVideo", withExtension: "mp4")!
let videoViewController = VideoViewController(videoURL: videoURL)
present(videoViewController, animated: true, completion: nil)
```

## Installation

### CocoaPods

``` ruby
pod 'VideoViewController'
```

### Manual

Add **VideoViewController** folder into your project.

## Contribution

Please feel free to submit pull requests. I think there is lots of things what can be done and how this component can be improved.

## Contact

Danil Gontovnik

- https://github.com/gontovnik
- https://twitter.com/gontovnik
- http://gontovnik.com/
- danil@gontovnik.com

## License

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
