//
//  ViewController.swift
//  VideoViewControllerExample
//
//  Created by Danil Gontovnik on 1/4/16.
//  Copyright © 2016 Danil Gontovnik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: -
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let videoURL = NSBundle.mainBundle().URLForResource("exampleVideo", withExtension: "mp4")!
        let videoViewController = VideoViewController(videoURL: videoURL)
        presentViewController(videoViewController, animated: true, completion: nil)
    }

}

