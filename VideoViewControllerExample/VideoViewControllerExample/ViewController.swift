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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let videoURL = Bundle.main.url(forResource: "exampleVideo", withExtension: "mp4")!
        let videoViewController = VideoViewController(videoURL: videoURL)
        present(videoViewController, animated: true, completion: nil)
    }

}

