# TabSlider
标签页切换组件,标签导航
实现横向类似tableView功能，首页标签栏和内容均可滚动，此demo适用于每个界面不用复用的情形。
假如标签栏有很多标签，但是所有标签展示的页面的布局几乎都不一样。容器页没有使用Scorllview来展示，
这种情况采用手势将新的view添加以及及时将远离的view移除掉。

关键代码：
```swift
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
   
