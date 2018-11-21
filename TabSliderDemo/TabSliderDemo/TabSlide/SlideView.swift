//
//  SlideView.swift
//  LadyBand
//
//  Created by jun on 2018/8/21.
//  Copyright © 2018年 com.ladyband. All rights reserved.
//

import UIKit
@objc protocol SlideViewDataSource:class {
    func numberOfControllersInSlide(_ slide:SlideView)->Int
    func slide(_ slide:SlideView,controllerAt index:Int)->UIViewController
    @objc optional func slide(_ slide:SlideView,didSelectedAt index:Int)
}
@objc protocol SlideViewDelegate:class {
    @objc optional func slide(_ slide:SlideView,switchingFrom oldIndex:Int,to newIndex:Int,percent:CGFloat)
    @objc optional func slide(_ slide:SlideView,didSwitchTo index:Int)
    @objc optional func slide(_ slide:SlideView,switchCanceled oldIndex:Int)
}
class SlideView: UIView {
    var selectedIndex:Int{
        get{
            return oldIndex
        }
        set{
            switchTo(index: newValue)
        }
    }
    var baseController:UIViewController!
    weak var delegate:SlideViewDelegate?
    weak var dataSource:SlideViewDataSource?
    func switchTo(index:Int) {
        if (oldIndex == index || isSwitching){return}
        guard let dataSource = dataSource else { return }
        
        if let oldCtrl = oldCtrl, oldCtrl.parent == baseController {
            isSwitching = true
            let newCtrl = dataSource.slide(self, controllerAt: index)
            oldCtrl.willMove(toParentViewController: nil)
            baseController.addChildViewController(newCtrl)
            let nowRect = oldCtrl.view.frame
            let leftRect = CGRect(x: nowRect.origin.x-nowRect.size.width, y: nowRect.origin.y, width: nowRect.size.width, height: nowRect.size.height)
            let rightRect = CGRect(x: nowRect.origin.x+nowRect.size.width, y: nowRect.origin.y, width: nowRect.size.width, height: nowRect.size.height)
            let newStartRect = index > oldIndex ? rightRect : leftRect
            let oldEndRect = index > oldIndex ? leftRect : rightRect
            newCtrl.view.frame = newStartRect
            newCtrl.willMove(toParentViewController: baseController)
            baseController.transition(from: oldCtrl, to: newCtrl, duration: 0.4, animations: {
                newCtrl.view.frame = nowRect
                oldCtrl.view.frame = oldEndRect
            }) { (finished) in
                oldCtrl.removeFromParentViewController()
                newCtrl.didMove(toParentViewController: self.baseController)
                self.delegate?.slide?(self, didSwitchTo: index)
                self.isSwitching = false
            }
            self.oldIndex = index
            self.oldCtrl = newCtrl
        }else{
            showAt(index: index)
        }
        willCtrl = nil
        panToIndex = -1
    }
    
    private func showAt(index:Int){
        if oldIndex == index {return}
        guard let dataSource = dataSource else { return  }
        removeOld()
        let vc = dataSource.slide(self, controllerAt: index)
        self.baseController.addChildViewController(vc)
        vc.view.frame = self.bounds
        self.addSubview(vc.view)
        vc.didMove(toParentViewController: baseController)
        oldIndex = index
        oldCtrl = vc
        delegate?.slide?(self, didSwitchTo: index)
    }
    
    private func removeCtrl(_ ctrl:UIViewController?){
        ctrl?.willMove(toParentViewController: nil)
        ctrl?.view.removeFromSuperview()
        ctrl?.removeFromParentViewController()
    }
    
    private func removeOld(){
        removeCtrl(oldCtrl)
        oldCtrl?.endAppearanceTransition()
        oldCtrl = nil
        oldIndex = -1
    }
    
    private func removeWill(){
        willCtrl?.beginAppearanceTransition(false, animated: false)
        removeCtrl(willCtrl)
        willCtrl?.endAppearanceTransition()
        willCtrl = nil
        panToIndex = -1
    }
    
    fileprivate let kPanSwitchOffsetThreshold:CGFloat = 50
    fileprivate var oldIndex:Int = -1
    fileprivate var panToIndex:Int = -1
    fileprivate lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
    fileprivate var panStartPoint:CGPoint?
    fileprivate var oldCtrl:UIViewController?
    fileprivate var willCtrl:UIViewController?
    fileprivate var isSwitching:Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        backgroundColor = .white
        addGestureRecognizer(pan)
    }
    private func repositionForOffsetX(_ offsetx:CGFloat){
        var x:CGFloat = 0
        if panToIndex < oldIndex{
            x = bounds.origin.x - bounds.size.width + offsetx
        }else if panToIndex > oldIndex{
            x = bounds.origin.x + bounds.size.width + offsetx
        }
        
        oldCtrl?.view.x = bounds.origin.x + offsetx
        willCtrl?.view.frame = (oldCtrl?.view.frame)!
        willCtrl?.view.x = x
        delegate?.slide?(self, switchingFrom: oldIndex, to: panToIndex, percent: fabs(offsetx)/self.width)
    }
    
    private func containsInControllers(_ index:Int)->Bool{
        return index >= 0 && index < (dataSource?.numberOfControllersInSlide(self) ?? 0)
    }
    
    private func backToOldWithOffset(_ offsetx:CGFloat){
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.repositionForOffsetX(0)
        }) { (finished) in
            if self.panToIndex != self.oldIndex{
                self.oldCtrl?.beginAppearanceTransition(true, animated: false)
                self.removeWill()
                self.oldCtrl?.endAppearanceTransition()
                self.delegate?.slide?(self, switchCanceled: self.oldIndex)
            }
        }
    }

    @objc private func panHandler(_ pan:UIPanGestureRecognizer){
        if oldIndex < 0 {return}
        guard let dataSource = dataSource else { return }
        let point = pan.translation(in: self)
        if pan.state == .began{
            panStartPoint = point
            oldCtrl?.beginAppearanceTransition(false, animated: true)
        }else if pan.state == .changed{
            let offsetx = point.x - panStartPoint!.x
            let panToIndex = offsetx > 0 ? oldIndex - 1 : oldIndex + 1
            if !containsInControllers(panToIndex){
                self.panToIndex = panToIndex
                repositionForOffsetX(offsetx/2)
            }else if panToIndex != self.panToIndex{
                removeWill()
                willCtrl = dataSource.slide(self, controllerAt: panToIndex)
                baseController.addChildViewController(willCtrl!)
                willCtrl?.willMove(toParentViewController: baseController)
                willCtrl?.beginAppearanceTransition(true, animated: true)
                addSubview(willCtrl!.view)
                self.panToIndex = panToIndex
            }
            repositionForOffsetX(offsetx)
        }else if pan.state == .ended{
            let offsetx = point.x - panStartPoint!.x
            if containsInControllers(self.panToIndex),self.panToIndex != oldIndex,fabs(offsetx) > kPanSwitchOffsetThreshold{
                let animatedTime = TimeInterval(fabs(self.width-fabs(offsetx))/self.width*0.4)
                UIView.animate(withDuration: animatedTime,  delay: 0, options: [.curveEaseInOut], animations: {
                    self.repositionForOffsetX(offsetx > 0 ? self.width : -self.width)
                }) { (finished) in
                    self.removeOld()
                    self.willCtrl?.endAppearanceTransition()
                    self.willCtrl?.didMove(toParentViewController: self.baseController)
                    self.oldIndex = self.panToIndex
                    self.oldCtrl = self.willCtrl
                    self.willCtrl = nil
                    self.panToIndex = -1
                    self.delegate?.slide?(self, didSwitchTo: self.oldIndex)
                    self.isSwitching = false
                }
            }else{
                backToOldWithOffset(offsetx)
            }
        }
    }
}
