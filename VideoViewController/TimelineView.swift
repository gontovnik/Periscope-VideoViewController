//
//  TimelineView.swift
//  VideoViewControllerExample
//
//  Created by Danil Gontovnik on 1/4/16.
//  Copyright © 2016 Danil Gontovnik. All rights reserved.
//

import UIKit

class TimelineView: UIView {
    
    // MARK: -  Vars
    
    var duration: Double = 0.0 {
        didSet { setNeedsDisplay() }
    }

    var initialTime: Double = 0.0 {
        didSet {
            currentTime = initialTime
        }
    }

    var currentTime: Double = 0.0 {
        didSet {
            setNeedsDisplay()
            currentTimeDidChange?(currentTime)
        }
    }

    private var _zoom: CGFloat = 1.0 {
        didSet { setNeedsDisplay() }
    }

    var zoom: CGFloat {
        get { return _zoom }
        set { _zoom = max(min(newValue, maxZoom), minZoom) }
    }

    var minZoom: CGFloat = 1.0 {
        didSet { zoom = _zoom }
    }

    var maxZoom: CGFloat = 3.5 {
        didSet { zoom = _zoom }
    }

    var intervalWidth: CGFloat = 24.0 {
        didSet { setNeedsDisplay() }
    }

    var intervalDuration: CGFloat = 15.0 {
        didSet { setNeedsDisplay() }
    }
    
    var currentTimeDidChange: ((Double) -> ())?
    
    // MARK: - Constructors
    
    init() {
        super.init(frame: .zero)
        
        opaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func currentIntervalWidth() -> CGFloat {
        return intervalWidth * zoom
    }

    func durationFromWidth(width: CGFloat) -> Double {
        return Double(width * intervalDuration / currentIntervalWidth())
    }

    func widthFromDuration(duration: Double) -> CGFloat {
        return currentIntervalWidth() * CGFloat(duration) / intervalDuration
    }

    func rewindByWidth(width: CGFloat) {
        let newCurrentTime = currentTime + durationFromWidth(width)
        currentTime = max(min(newCurrentTime, duration), 0.0)
    }
    
    // MARK: - Draw
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let intervalWidth = currentIntervalWidth()
        
        let originX: CGFloat = bounds.width / 2.0 - widthFromDuration(currentTime)
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
        
        let elapsedPath = UIBezierPath(roundedRect: CGRect(x: originX, y: 0.0, width: widthFromDuration(currentTime), height: lineHeight), cornerRadius: lineHeight).CGPath
        CGContextAddPath(context, elapsedPath)
        CGContextFillPath(context)
        
        // Draw current time dot
        CGContextFillEllipseInRect(context, CGRect(x: originX + widthFromDuration(initialTime), y: 7.0, width: 3.0, height: 3.0))
        
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
