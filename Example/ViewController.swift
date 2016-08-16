//
//  ViewController.swift
//  VideoRangeSlider
//
//  Created by Amr Mohamed on 7/7/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//

import UIKit
import AVFoundation
import AMVideoRangeSlider

class ViewController: UIViewController , AMVideoRangeSliderDelegate {

    @IBOutlet weak var videoRangeSlider: AMVideoRangeSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSBundle.mainBundle().URLForResource("video", withExtension: "mp4")
        self.videoRangeSlider.videoAsset = AVAsset(URL: url!)
        self.videoRangeSlider.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func rangeSliderLowerThumbValueChanged() {
        print(self.videoRangeSlider.startTime.seconds)
    }
    
    func rangeSliderMiddleThumbValueChanged() {
        print(self.videoRangeSlider.currentTime.seconds)
    }
    
    func rangeSliderUpperThumbValueChanged() {
        print(self.videoRangeSlider.stopTime.seconds)
    }
    
}