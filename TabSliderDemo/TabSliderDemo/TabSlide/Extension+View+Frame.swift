//
//  Extension+View+Frame.swift
//  TabSliderDemo
//
//  Created by jun on 2018/11/21.
//  Copyright © 2018 ayzk. All rights reserved.
//

import UIKit

// MARK: - 设置ViewFarme相关属性
public extension UIView{
    
    /// view的x
    public var x: CGFloat{
        get{ return frame.origin.x }
        set{ self.frame.origin.x = newValue }
    }
    
    /// view的y
    public var y: CGFloat{
        get{ return frame.origin.y }
        set{ self.frame.origin.y = newValue }
    }
    
    /// view的宽度
    public var width: CGFloat {
        get{ return self.frame.size.width }
        set{
            var frameCopy = frame
            frameCopy.size.width = newValue
            frame = frameCopy
        }
    }
    
    /// view的高度
    public var height: CGFloat {
        get{ return self.frame.size.height }
        set{ var frameCopy = frame
            frameCopy.size.height = newValue
            frame = frameCopy
        }
    }
    
    /// view中心X值
    public var centerX: CGFloat{
        get{ return self.center.x }
        set{ self.center = CGPoint(x: newValue, y: self.center.y) }
    }
    
    /// view中心Y值
    public var centerY: CGFloat{
        get{ return self.center.y }
        set{ self.center = CGPoint(x: self.center.y, y: newValue) }
    }
    
    /// view的size
    public var size: CGSize{
        get{ return self.frame.size }
        set{
            var frameCopy = frame
            frameCopy.size = newValue
            frame = frameCopy
        }
    }
    
    /// view的origin
    public var origin: CGPoint {
        get{ return self.frame.origin }
        set{
            var frameCopy = frame
            frameCopy.origin = newValue
            frame = frameCopy
        }
    }
    
    var viewCenter: CGPoint{
        get{return CGPoint(x: width * 0.5, y: height * 0.5)}
    }
    
    var maxX: CGFloat{
        get{return self.x + self.width}
        set{x = newValue - self.width}
    }
    var maxY: CGFloat{
        get{return self.y + self.height}
        set{y = newValue - self.height}
    }
}
