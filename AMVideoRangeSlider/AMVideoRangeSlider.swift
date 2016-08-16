//
//  RangeSlider.swift
//  VideoPlayer
//
//  Created by Amr Mohamed on 4/5/16.
//  Copyright © 2016 Amr Mohamed. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import QuartzCore
import AVFoundation

internal class AMVideoRangeSliderThumbLayer: CAShapeLayer {
    var highlighted = false
    weak var rangeSlider : AMVideoRangeSlider?
    
    override func layoutSublayers() {
        super.layoutSublayers()
        self.cornerRadius = self.bounds.width / 2
        self.setNeedsDisplay()
    }
    
    override func drawInContext(ctx: CGContext) {
        CGContextMoveToPoint(ctx, self.bounds.width/2, self.bounds.height/5)
        CGContextAddLineToPoint(ctx, self.bounds.width/2 , self.bounds.height - self.bounds.height/5)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextStrokePath(ctx)
    }
}

internal class AMVideoRangeSliderTrackLayer: CAShapeLayer {
    
    weak var rangeSlider : AMVideoRangeSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
            let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
            CGContextSetFillColorWithColor(ctx, slider.sliderTintColor.CGColor)
            CGContextFillRect(ctx, rect)
        }
    }
}

public protocol AMVideoRangeSliderDelegate {
    func rangeSliderLowerThumbValueChanged()
    func rangeSliderMiddleThumbValueChanged()
    func rangeSliderUpperThumbValueChanged()
}

public class AMVideoRangeSlider: UIControl {
    
    public var middleValue = 0.0 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    public var minimumValue: Double = 0.0 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    public var maximumValue: Double = 1.0 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    public var lowerValue: Double = 0.0 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    public var upperValue: Double = 1.0 {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    public var videoAsset : AVAsset? {
        didSet {
            self.generateVideoImages()
        }
    }
    
    public var currentTime : CMTime {
        return CMTimeMakeWithSeconds(self.videoAsset!.duration.seconds * self.middleValue, self.videoAsset!.duration.timescale)
    }
    
    public var startTime : CMTime! {
        return CMTimeMakeWithSeconds(self.videoAsset!.duration.seconds * self.lowerValue, self.videoAsset!.duration.timescale)
    }
    
    public var stopTime : CMTime! {
        return CMTimeMakeWithSeconds(self.videoAsset!.duration.seconds * self.upperValue, self.videoAsset!.duration.timescale)
    }
    
    public var rangeTime : CMTimeRange! {
        let lower = self.videoAsset!.duration.seconds * self.lowerValue
        let upper = self.videoAsset!.duration.seconds * self.upperValue
        let duration = CMTimeMakeWithSeconds(upper - lower, self.videoAsset!.duration.timescale)
        return CMTimeRangeMake(self.startTime, duration)
    }
    
    public var sliderTintColor = UIColor(red:0.97, green:0.71, blue:0.19, alpha:1.00) {
        didSet {
            self.lowerThumbLayer.backgroundColor = self.sliderTintColor.CGColor
            self.upperThumbLayer.backgroundColor = self.sliderTintColor.CGColor
            
        }
    }
    
    public var middleThumbTintColor : UIColor! {
        didSet {
            self.middleThumbLayer.backgroundColor = self.middleThumbTintColor.CGColor
        }
    }
    
    public var delegate : AMVideoRangeSliderDelegate?
    
    var middleThumbLayer = AMVideoRangeSliderThumbLayer()
    var lowerThumbLayer = AMVideoRangeSliderThumbLayer()
    var upperThumbLayer = AMVideoRangeSliderThumbLayer()
    
    var trackLayer = AMVideoRangeSliderTrackLayer()
    
    var previousLocation = CGPoint()
    
    var thumbWidth : CGFloat {
        return 15
    }
    
    var thumpHeight : CGFloat {
        return self.bounds.height + 10
    }
    
    public override var frame: CGRect {
        didSet {
            self.updateLayerFrames()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init(coder : NSCoder) {
        super.init(coder: coder)!
        self.commonInit()
    }
    
    public override func layoutSubviews() {
        self.updateLayerFrames()
    }
    
    func commonInit() {
        self.trackLayer.rangeSlider = self
        self.middleThumbLayer.rangeSlider = self
        self.lowerThumbLayer.rangeSlider = self
        self.upperThumbLayer.rangeSlider = self
        
        self.layer.addSublayer(self.trackLayer)
        self.layer.addSublayer(self.middleThumbLayer)
        self.layer.addSublayer(self.lowerThumbLayer)
        self.layer.addSublayer(self.upperThumbLayer)
        
        self.middleThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        self.lowerThumbLayer.backgroundColor = self.sliderTintColor.CGColor
        self.upperThumbLayer.backgroundColor = self.sliderTintColor.CGColor
        
        self.trackLayer.contentsScale = UIScreen.mainScreen().scale
        self.lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        self.upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        
        self.updateLayerFrames()
    }
    
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.trackLayer.frame = self.bounds
        self.trackLayer.setNeedsDisplay()
        
        let middleThumbCenter = CGFloat(self.positionForValue(self.middleValue))
        self.middleThumbLayer.frame = CGRect(x: middleThumbCenter - self.thumbWidth / 2, y: -5.0, width: 2, height: self.thumpHeight)
        
        let lowerThumbCenter = CGFloat(self.positionForValue(self.lowerValue))
        self.lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - self.thumbWidth / 2, y: -5.0, width: self.thumbWidth, height: self.thumpHeight)
        
        let upperThumbCenter = CGFloat(self.positionForValue(self.upperValue))
        self.upperThumbLayer.frame = CGRect(x: upperThumbCenter - self.thumbWidth / 2, y: -5.0, width: self.thumbWidth, height: self.thumpHeight)
        
        CATransaction.commit()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(self.bounds.width - self.thumbWidth) * (value - self.minimumValue) / (self.maximumValue - self.minimumValue) + Double(self.thumbWidth / 2.0)
    }
    
    public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        self.previousLocation = touch.locationInView(self)
        
        if self.lowerThumbLayer.frame.contains(self.previousLocation) {
            self.lowerThumbLayer.highlighted = true
        } else if self.upperThumbLayer.frame.contains(self.previousLocation) {
            self.upperThumbLayer.highlighted = true
        } else {
            self.middleThumbLayer.highlighted = true
        }
        
        return self.lowerThumbLayer.highlighted || self.upperThumbLayer.highlighted || self.middleThumbLayer.highlighted
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        let deltaLocation = Double(location.x - self.previousLocation.x)
        let deltaValue = (self.maximumValue - self.minimumValue) * deltaLocation / Double(self.bounds.width - self.thumbWidth)
        let newMiddle = Double(self.previousLocation.x) / Double(self.bounds.width - self.thumbWidth)
        
        self.previousLocation = location
        
        if self.lowerThumbLayer.highlighted {
            if deltaValue > 0 && self.rangeTime.duration.seconds <= 1{
                
            } else {
                self.lowerValue += deltaValue
                self.lowerValue = self.boundValue(self.lowerValue, toLowerValue: self.minimumValue, upperValue: self.maximumValue)
                self.delegate?.rangeSliderLowerThumbValueChanged()
            }
            
        } else if self.middleThumbLayer.highlighted {
            self.middleValue = newMiddle
            self.middleValue = self.boundValue(self.middleValue, toLowerValue: self.lowerValue, upperValue: self.upperValue)
            self.delegate?.rangeSliderMiddleThumbValueChanged()
        } else if self.upperThumbLayer.highlighted {
            if deltaValue < 0 && self.rangeTime.duration.seconds <= 1 {
                
            } else {
                self.upperValue += deltaValue
                self.upperValue = self.boundValue(self.upperValue, toLowerValue: self.minimumValue, upperValue: self.maximumValue)
                self.delegate?.rangeSliderUpperThumbValueChanged()
            }
        }
        
        self.sendActionsForControlEvents(.ValueChanged)
        return true
    }
    
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        self.lowerThumbLayer.highlighted = false
        self.middleThumbLayer.highlighted = false
        self.upperThumbLayer.highlighted = false
    }
    
    func generateVideoImages() {
        dispatch_async(dispatch_get_main_queue(), {
            
            self.lowerValue = 0.0
            self.upperValue = 1.0
            
            for subview in self.subviews {
                if subview is UIImageView {
                    subview.removeFromSuperview()
                }
            }
            
            let imageGenerator = AVAssetImageGenerator(asset: self.videoAsset!)
            
            let assetDuration = CMTimeGetSeconds(self.videoAsset!.duration)
            var Times = [NSValue]()
            
            let numberOfImages = Int((self.frame.width / self.frame.height))
            
            for index in 1...numberOfImages {
                let point = CMTimeMakeWithSeconds(assetDuration/Double(index), 600)
                Times += [NSValue(CMTime: point)]
            }
            
            Times = Times.reverse()
            
            let imageWidth = self.frame.width/CGFloat(numberOfImages)
            var imageFrame = CGRect(x: 0, y: 2, width: imageWidth, height: self.frame.height-4)
            
            imageGenerator.generateCGImagesAsynchronouslyForTimes(Times) { (requestedTime, image, actualTime, result, error) in
                if error == nil {
                    
                    if result == AVAssetImageGeneratorResult.Succeeded {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            let imageView = UIImageView(image: UIImage(CGImage: image!))
                            imageView.contentMode = .ScaleAspectFill
                            imageView.clipsToBounds = true
                            imageView.frame = imageFrame
                            imageFrame.origin.x += imageWidth
                            self.insertSubview(imageView, atIndex:1)
                        })
                    }
                    
                    if result == AVAssetImageGeneratorResult.Failed {
                        print("Generating Fail")
                    }
                    
                } else {
                    print("Error at generating images : \(error!.description)")
                }
            }
            
        })
        
    }
    
}
