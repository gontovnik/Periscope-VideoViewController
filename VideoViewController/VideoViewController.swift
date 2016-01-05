//
//  VideoViewController.swift
//  VideoViewControllerExample
//
//  Created by Danil Gontovnik on 1/4/16.
//  Copyright © 2016 Danil Gontovnik. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {
    
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
    private let rewindTimelineView = TimelineView()
    
    private let rewindPreviewShadowLayer = CALayer()
    private let rewindPreviewImageView = UIImageView()
    private let rewindCurrentTimeLabel = UILabel()

    var rewindPreviewMaxHeight: CGFloat = 112.0 {
        didSet {
            assetGenerator.maximumSize = CGSize(width: CGFloat.max, height: rewindPreviewMaxHeight * UIScreen.mainScreen().scale)
        }
    }

    // MARK: - Constructors

    init(videoURL: NSURL) {
        super.init(nibName: nil, bundle: nil)
        
        self.videoURL = videoURL
        
        asset = AVURLAsset(URL: videoURL)
        
        playerItem = AVPlayerItem(asset: asset)
        
        player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .None
        
        playerLayer = AVPlayerLayer(player: player)
        
        assetGenerator = AVAssetImageGenerator(asset: asset)
        assetGenerator.maximumSize = CGSize(width: CGFloat.max, height: rewindPreviewMaxHeight * UIScreen.mainScreen().scale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    override func loadView() {
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
                    strongSelf.layoutRewindPreviewImageViewIfNeeded()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.play()
    }

    // MARK: - Methods
    
    func longPressed(gesture: UILongPressGestureRecognizer) {
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
            rewindTimelineView.rewindByWidth(previousLocationX - location.x)
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

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - Layout

    override func viewWillLayoutSubviews() {
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
        
        layoutRewindPreviewImageViewIfNeeded()
    }
    
    private func layoutRewindPreviewImageViewIfNeeded() {
        guard let image = rewindPreviewImageView.image where rewindPreviewImageView.bounds.size != image.size else {
            return
        }
        
        rewindPreviewImageView.frame = CGRect(x: (rewindContentView.bounds.width - image.size.width) / 2.0, y: rewindPreviewImageView.frame.minY, width: image.size.width, height: rewindPreviewImageView.bounds.height)
        rewindPreviewShadowLayer.frame = rewindPreviewImageView.frame

        let path = UIBezierPath(roundedRect: rewindPreviewImageView.bounds, cornerRadius: 5.0).CGPath
        rewindPreviewShadowLayer.shadowPath = path
        (rewindPreviewImageView.layer.mask as! CAShapeLayer).path = path
    }

}
