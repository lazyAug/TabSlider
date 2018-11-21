//
//  TabSliderView.swift
//  LadyBand
//
//  Created by jun on 2018/8/21.
//  Copyright © 2018年 com.ladyband. All rights reserved.
//

import UIKit
///tab的类型
enum TabSlideType {
    ///固定
    case fixed
    ///滑动
    case scroll(itemWidth:CGFloat)
}
///指示器类型
enum TabSlideTrackWidthType {
    ///固定大小
    case fixed
    ///根据标题大小
    case title_image
}

/// 每一个tab mode
struct TabSlideItem {
    var title:String = ""
    var image:UIImage?
    var selectedImage:UIImage?
    var titleColor:UIColor = .black
    var selectedTitleColor:UIColor = .orange
    
    init(title:String,titleColor:UIColor = .darkText,selectedTitleColor:UIColor = UIColor.orange) {
        self.title = title
        self.titleColor = titleColor
        self.selectedTitleColor = selectedTitleColor
    }
    init(title:String,image:UIImage?,selectedImage:UIImage?,titleColor:UIColor = .black,selectedTitleColor:UIColor = .orange) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.titleColor = titleColor
        self.selectedTitleColor = selectedTitleColor
    }
}

@objc protocol TabSlideViewDelegate:class {
    func tabSlide(_ tabSlide:TabSlideView,controllerAt index:Int)->UIViewController
    @objc optional func tabSlide(_ tabSlide:TabSlideView,didSelectedAt index:Int)
}

extension TabSlideView:TabbarDelegate,SlideViewDelegate,SlideViewDataSource{
    func slide(_ slide: SlideView, didSelectedAt index: Int) {
        self.delegate?.tabSlide?(self, didSelectedAt: index)
    }
    func numberOfControllersInSlide(_ slide: SlideView) -> Int {
        return tabbar.tabbarItems.count
    }
    func slide(_ slide: SlideView, controllerAt index: Int) -> UIViewController {
        if let object = cache.object(forKey: String(index)){
            return object as! UIViewController
        }
        if let delegate = self.delegate{
            let vc =  delegate.tabSlide(self, controllerAt: index)
            cache.set(object: vc, forKey: String(index))
            return vc
        }
        return UIViewController()
    }
    func tabbar(_ tabbar: TabbarView, selectAt index: Int) {
        slide.selectedIndex = index
    }
    func slide(_ slide: SlideView, didSwitchTo index: Int) {
        tabbar.selectedIndex = index
        self.slide(slide, didSelectedAt: index)
    }
    func slide(_ slide: SlideView, switchCanceled oldIndex: Int) {
        tabbar.selectedIndex = oldIndex
    }
    func slide(_ slide: SlideView, switchingFrom oldIndex: Int, to newIndex: Int, percent: CGFloat) {
        tabbar.switching(fromIndex: oldIndex, toIndex: newIndex, percent: percent)
    }
}
class TabSlideView: UIView {
    convenience init(trackWidth:TabSlideTrackWidthType,bottomSpacing:CGFloat = 2) {
        self.init()
        tabbarTrackWidthType = trackWidth
        tabbarBottomSpacing = bottomSpacing
        tabbarTrackColor = UIColor.orange
        backgroundColor = .white
        slide.backgroundColor = .white
        tabbar.backgroundColor = .white
    }
    ///tab的类型
    var tabbarType:TabSlideType{
        set{tabbar.type = newValue}
        get{return tabbar.type}
    }
    ///tab高度
    var tabbarHeight:CGFloat = 44{
        didSet{layoutSubviews()}
    }
    var tabbarBottomSpacing:CGFloat=2{
        didSet{layoutSubviews()}
    }
    ///
    var tabbarBackgroundImage:UIImage?{
        set{tabbar.backgroundImage = newValue}
        get{ return tabbar.backgroundImage}
    }
    ///指示器颜色
    var tabbarTrackColor:UIColor?{
        set{tabbar.trackColor = newValue}
        get{return tabbar.trackColor}
    }
    ///指示器高度
    var trackHeight:CGFloat{
        set{tabbar.trackHeight=newValue}
        get{return tabbar.trackHeight}
    }
    ///指示器类型
    var tabbarTrackWidthType:TabSlideTrackWidthType{
        set{tabbar.trackWidthType = newValue}
        get{return tabbar.trackWidthType}
    }
    ///tab列表
    var tabbarItems:[TabSlideItem]{
        set{tabbar.tabbarItems = newValue}
        get{return tabbar.tabbarItems}
    }
    ///当前项
    var selectedIndex:Int{
        set{tabbar.selectedIndex = newValue;slide.selectedIndex = newValue}
        get{return slide.selectedIndex}
    }
    ///父容器
    var baseController:UIViewController{
        set{slide.baseController = newValue}
        get{return slide.baseController}
    }
    weak var delegate:TabSlideViewDelegate?
    private(set) lazy var slide = SlideView(frame: slideFrame)
    private(set) lazy var tabbar = TabbarView(frame: tabbarFrame)
    private lazy var cache = TabCache(count: tabbar.tabbarItems.count)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        tabbar.delegate = self
        slide.delegate = self
        slide.dataSource = self
        addSubview(tabbar)
        addSubview(slide)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tabbar.frame = tabbarFrame
        slide.frame = slideFrame
    }
    
    private var tabbarFrame:CGRect{
        return CGRect(x: 0, y: 0, width: self.width, height: self.tabbarHeight)
    }
    private var slideFrame:CGRect{
        return CGRect(x: 0, y: self.tabbarHeight + self.tabbarBottomSpacing, width: self.width, height: self.height - self.tabbarBottomSpacing - self.tabbarHeight)
    }
}
