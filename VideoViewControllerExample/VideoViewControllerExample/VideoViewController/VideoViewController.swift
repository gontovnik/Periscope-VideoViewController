// VideoViewController.swift
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
import AVFoundation

public class VideoViewController: UIViewController {
    
    // MARK: - Vars

    private var videoURL: NSURL!

    private var asset: AVURLAsset!
    private var playerItem: AVPlayerItem!
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var assetGenerator: AVAssetImageGenerator!
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    private var previousLocationX: CGFloat = 0.0
    
    private let rewindDimView = UIVisualEffectView()
    private let rewindContentView = UIView()
    public let rewindTimelineView = TimelineView()
    private let rewindPreviewShadowLayer = CALayer()
    private let rewindPreviewImageView = UIImageView()
    private let rewindCurrentTimeLabel = UILabel()

    /// Indicates the maximum height of rewindPreviewImageView. Default value is 112.
    public var rewindPreviewMaxHeight: CGFloat = 112.0 {
        didSet {
            assetGenerator.maximumSize = CGSize(width: CGFloat.max, height: rewindPreviewMaxHeight * UIScreen.mainScreen().scale)
        }
    }
    
    /// Indicates whether player should start playing on viewDidLoad. Default is true. 
    public var autoplays: Bool = true

    // MARK: - Constructors

    /**
        Returns an initialized VideoViewController object
    
        - Parameter videoURL: Local URL to the video asset 
    */
    public init(videoURL: NSURL) {
        super.init(nibName: nil, bundle: nil)
        
        self.videoURL = videoURL
        
        asset = AVURLAsset(URL: videoURL)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)

        assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.maximumSize = CGSize(width: CGFloat.max, height: rewindPreviewMaxHeight * UIScreen.mainScreen().scale)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    override public func loadView() {
        super.loadView()
        
        view.backgroundColor = .blackColor()
        view.layer.addSublayer(playerLayer)
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPressed:"))
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        view.addSubview(rewindDimView)
        
        rewindContentView.alpha = 0.0
        view.addSubview(rewindContentView)
        
        rewindTimelineView.duration = CMTimeGetSeconds(asset.duration)
        rewindTimelineView.currentTimeDidChange = { [weak self] (currentTime) in
            guard let strongSelf = self, playerItem = strongSelf.playerItem, assetGenerator = strongSelf.assetGenerator else { return }
            
            let minutesInt = Int(currentTime / 60.0)
            let secondsInt = Int(currentTime) - minutesInt * 60
            strongSelf.rewindCurrentTimeLabel.text = (minutesInt > 9 ? "" : "0") + "\(minutesInt)" + ":" + (secondsInt > 9 ? "" : "0") + "\(secondsInt)"
            
            let requestedTime = CMTime(seconds: currentTime, preferredTimescale: playerItem.currentTime().timescale)
            
            assetGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: requestedTime)]) { [weak self] (_, CGImage, _, _, _) in
                guard let strongSelf = self, CGImage = CGImage else { return }
                let image = UIImage(CGImage: CGImage, scale: UIScreen.mainScreen().scale, orientation: .Up)

                dispatch_async(dispatch_get_main_queue()) {
                    strongSelf.rewindPreviewImageView.image = image
                    
                    if strongSelf.rewindPreviewImageView.bounds.size != image.size {
                        strongSelf.viewWillLayoutSubviews()
                    }
                }
            }
        }
        rewindContentView.addSubview(rewindTimelineView)
        
        rewindCurrentTimeLabel.text = " "
        rewindCurrentTimeLabel.font = .systemFontOfSize(16.0)
        rewindCurrentTimeLabel.textColor = .whiteColor()
        rewindCurrentTimeLabel.textAlignment = .Center
        rewindCurrentTimeLabel.sizeToFit()
        rewindContentView.addSubview(rewindCurrentTimeLabel)
        
        rewindPreviewShadowLayer.shadowOpacity = 1.0
        rewindPreviewShadowLayer.shadowColor = UIColor(white: 0.1, alpha: 1.0).CGColor
        rewindPreviewShadowLayer.shadowRadius = 15.0
        rewindPreviewShadowLayer.shadowOffset = .zero
        rewindPreviewShadowLayer.masksToBounds = false
        rewindPreviewShadowLayer.actions = ["position": NSNull(), "bounds": NSNull(), "shadowPath": NSNull()]
        rewindContentView.layer.addSublayer(rewindPreviewShadowLayer)

        rewindPreviewImageView.contentMode = .ScaleAspectFit
        rewindPreviewImageView.layer.mask = CAShapeLayer()
        rewindContentView.addSubview(rewindPreviewImageView)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if autoplays {
            play()
        }
    }

    // MARK: - Methods
    
    /// Resumes playback
    public func play() {
        player.play()
    }
    
    /// Pauses playback
    public func pause() {
        player.pause()
    }
    
    public func longPressed(gesture: UILongPressGestureRecognizer) {
        let location = gesture.locationInView(gesture.view!)
        rewindTimelineView.zoom = (location.y - rewindTimelineView.center.y - 10.0) / 30.0
        
        if gesture.state == .Began {
            player.pause()
            rewindTimelineView.initialTime = CMTimeGetSeconds(playerItem.currentTime())
            UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseOut], animations: {
                self.rewindDimView.effect = UIBlurEffect(style: .Dark)
                self.rewindContentView.alpha = 1.0
                }, completion: nil)
        } else if gesture.state == .Changed {
            rewindTimelineView.rewindByDistance(previousLocationX - location.x)
        } else {
            player.play()
            
            let newTime = CMTime(seconds: rewindTimelineView.currentTime, preferredTimescale: playerItem.currentTime().timescale)
            playerItem.seekToTime(newTime)
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: [.CurveEaseOut], animations: {
                self.rewindDimView.effect = nil
                self.rewindContentView.alpha = 0.0
                }, completion: nil)
        }
        
        if previousLocationX != location.x {
            previousLocationX = location.x
        }
    }

    override public func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - Layout

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        playerLayer.frame = view.bounds
        rewindDimView.frame = view.bounds
        
        rewindContentView.frame = view.bounds
        
        let timelineHeight: CGFloat = 10.0
        let verticalSpacing: CGFloat = 25.0
        
        let rewindPreviewImageViewWidth = rewindPreviewImageView.image?.size.width ?? 0.0
        rewindPreviewImageView.frame = CGRect(x: (rewindContentView.bounds.width - rewindPreviewImageViewWidth) / 2.0, y: (rewindContentView.bounds.height - rewindPreviewMaxHeight - verticalSpacing - rewindCurrentTimeLabel.bounds.height - verticalSpacing - timelineHeight) / 2.0, width: rewindPreviewImageViewWidth, height: rewindPreviewMaxHeight)
        rewindCurrentTimeLabel.frame = CGRect(x: 0.0, y: rewindPreviewImageView.frame.maxY + verticalSpacing, width: rewindTimelineView.bounds.width, height: rewindCurrentTimeLabel.frame.height)
        rewindTimelineView.frame = CGRect(x: 0.0, y: rewindCurrentTimeLabel.frame.maxY + verticalSpacing, width: rewindContentView.bounds.width, height: timelineHeight)
        rewindPreviewShadowLayer.frame = rewindPreviewImageView.frame
        
        let path = UIBezierPath(roundedRect: rewindPreviewImageView.bounds, cornerRadius: 5.0).CGPath
        rewindPreviewShadowLayer.shadowPath = path
        (rewindPreviewImageView.layer.mask as! CAShapeLayer).path = path
    }

}
