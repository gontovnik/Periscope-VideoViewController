// TimelineView.swift
//
// Copyright (c) 2016 Danil Gontovnik (http://gontovnik.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public class TimelineView: UIView {
    
    // MARK: -  Vars
    
    /// The duration of the video in seconds.
    public var duration: NSTimeInterval = 0.0 {
        didSet { setNeedsDisplay() }
    }

    /// Time in seconds when rewind began.
    public var initialTime: NSTimeInterval = 0.0 {
        didSet {
            currentTime = initialTime
        }
    }

    /// Current timeline time in seconds.
    public var currentTime: NSTimeInterval = 0.0 {
        didSet {
            setNeedsDisplay()
            currentTimeDidChange?(currentTime)
        }
    }

    /// Internal zoom variable.
    private var _zoom: CGFloat = 1.0 {
        didSet { setNeedsDisplay() }
    }

    /// The zoom of the timeline view. The higher zoom value, the more accurate rewind is. Default is 1.0.
    public var zoom: CGFloat {
        get { return _zoom }
        set { _zoom = max(min(newValue, maxZoom), minZoom) }
    }

    /// Indicates minimum zoom value. Default is 1.0.
    public var minZoom: CGFloat = 1.0 {
        didSet { zoom = _zoom }
    }

    /// Indicates maximum zoom value. Default is 3.5.
    public var maxZoom: CGFloat = 3.5 {
        didSet { zoom = _zoom }
    }

    /// The width of a line representing a specific time interval on a timeline. If zoom is not equal 1, then actual interval width equals to intervalWidth * zoom. Value will be used during rewind for calculations — for example, if zoom is 1, intervalWidth is 30 and intervalDuration is 15, then when user moves 10pixels left or right we will rewind by +5 or -5 seconds;
    public var intervalWidth: CGFloat = 24.0 {
        didSet { setNeedsDisplay() }
    }

    /// The duration of an interval in seconds. If video is 55 seconds and interval is 15 seconds — then we will have 3 full intervals and one not full interval. Value will be used during rewind for calculations.
    public var intervalDuration: CGFloat = 15.0 {
        didSet { setNeedsDisplay() }
    }
    
    /// Block which will be triggered everytime currentTime value changes.
    public var currentTimeDidChange: ((NSTimeInterval) -> ())?
    
    // MARK: - Constructors
    
    public init() {
        super.init(frame: .zero)
        
        opaque = false
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    /**
        Calculate current interval width. It takes two variables in count - intervalWidth and zoom.
    */
    private func currentIntervalWidth() -> CGFloat {
        return intervalWidth * zoom
    }

    /**
        Calculates time interval in seconds from passed width.
     
        - Parameter width: The distance.
    */
    public func timeIntervalFromDistance(distance: CGFloat) -> NSTimeInterval {
        return NSTimeInterval(distance * intervalDuration / currentIntervalWidth())
    }

    /**
        Calculates distance from given time interval.
        
        - Parameter duration: The duration of an interval.
    */
    public func distanceFromTimeInterval(timeInterval: NSTimeInterval) -> CGFloat {
        return currentIntervalWidth() * CGFloat(timeInterval) / intervalDuration
    }

    /**
        Rewinds by distance. Calculates interval width and adds it to the current time.
     
        - Parameter distance: The distance how far it should rewind by.
    */
    public func rewindByDistance(distance: CGFloat) {
        let newCurrentTime = currentTime + timeIntervalFromDistance(distance)
        currentTime = max(min(newCurrentTime, duration), 0.0)
    }
    
    // MARK: - Draw
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let intervalWidth = currentIntervalWidth()
        
        let originX: CGFloat = bounds.width / 2.0 - distanceFromTimeInterval(currentTime)
        let context = UIGraphicsGetCurrentContext()
        let lineHeight: CGFloat = 5.0
        
        // Calculate how many intervals it contains
        let intervalsCount = CGFloat(duration) / intervalDuration
        
        // Draw full line
        CGContextSetFillColorWithColor(context, UIColor(white: 0.45, alpha: 1.0).CGColor)
        
        let totalPath = UIBezierPath(roundedRect: CGRect(x: originX, y: 0.0, width: intervalWidth * intervalsCount, height: lineHeight), cornerRadius: lineHeight).CGPath
        CGContextAddPath(context, totalPath)
        CGContextFillPath(context)
        
        // Draw elapsed line
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        
        let elapsedPath = UIBezierPath(roundedRect: CGRect(x: originX, y: 0.0, width: distanceFromTimeInterval(currentTime), height: lineHeight), cornerRadius: lineHeight).CGPath
        CGContextAddPath(context, elapsedPath)
        CGContextFillPath(context)
        
        // Draw current time dot
        CGContextFillEllipseInRect(context, CGRect(x: originX + distanceFromTimeInterval(initialTime), y: 7.0, width: 3.0, height: 3.0))
        
        // Draw full line separators
        CGContextSetFillColorWithColor(context, UIColor(white: 0.0, alpha: 0.5).CGColor)
        
        var intervalIdx: CGFloat = 0.0
        repeat {
            intervalIdx += 1.0
            if intervalsCount - intervalIdx > 0.0 {
                CGContextFillRect(context, CGRect(x: originX + intervalWidth * intervalIdx, y: 0.0, width: 1.0, height: lineHeight))
            }
        } while intervalIdx < intervalsCount
    }

}
