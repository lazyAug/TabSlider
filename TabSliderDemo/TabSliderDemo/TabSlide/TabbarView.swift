//
//  FixedTabbarView.swift
//  LadyBand
//
//  Created by jun on 2018/8/21.
//  Copyright © 2018年 com.ladyband. All rights reserved.
//

import UIKit
protocol TabbarDelegate:class {
    func tabbar(_ tabbar:TabbarView, selectAt index:Int)
}

protocol TabbarProtocol:class{
    var selectedIndex:Int{get set}
    var tabbarItems:[TabSlideItem]{get set}
    var delegate:TabbarDelegate?{set get}
    var type:TabSlideType{set get}
    func switching(fromIndex:Int,toIndex:Int,percent:CGFloat)
}

class TabbarView: UIView, TabbarProtocol{
    private let kImageSpacingX:CGFloat = 2
    private let kTabItemTagBase = 1000
    var type: TabSlideType = .fixed
    var backgroundImage:UIImage?{
        didSet{
            backgroundView.image = backgroundImage
        }
    }
    var trackColor:UIColor?{
        didSet{
            trackView.backgroundColor = trackColor
        }
    }
    var trackWidthType:TabSlideTrackWidthType = .fixed
    var trackHeight:CGFloat = 4{
        didSet{
            trackView.height = trackHeight
        }
    }
    var selectedIndex: Int = -1{
        didSet{
            if oldValue == -1{
                layoutTabbar()
            }else{
                switching(fromIndex: oldValue, toIndex: selectedIndex, percent: 1)
            }
        }
    }
    
    var tabbarItems = [TabSlideItem](){
        didSet{
            let width = itemWidth
            var x:CGFloat = 0
            for (index,item) in tabbarItems.enumerated(){
                x += width
                let backView = UIView()
                let label = UILabel()
                let imageView = UIImageView(image: item.image)
                let selectedImageView = UIImageView(image: item.selectedImage)
                label.textColor = item.titleColor
                label.text = item.title
                label.font = UIFont.systemFont(ofSize: 14)
                label.sizeToFit()
                backView.frame = CGRect(x: x, y: 0, width: width, height: height)
                backView.tag = kTabItemTagBase + index
                backView.addSubview(label)
                backView.addSubview(imageView)
                backView.addSubview(selectedImageView)
                scrollView.addSubview(backView)
            }
            scrollView.contentSize = CGSize(width: x, height: height)
        }
    }
    
    weak var delegate: TabbarDelegate?
    private func getColorOf(percent:CGFloat,between color1:UIColor, and color2:UIColor)->UIColor{
        let p1 = percent
        let p2 = 1.0 - percent
        var red1:CGFloat = 0, green1:CGFloat = 0,blue1:CGFloat = 0,alpha1:CGFloat = 0
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        var red2:CGFloat = 0, green2:CGFloat = 0,blue2:CGFloat = 0,alpha2:CGFloat = 0
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        let mid = UIColor(red: red1*p1+red2*p2, green: green1*p1+green2*p2, blue: blue1*p1+blue2*p2, alpha: 1)
        return mid
    }

    func switching(fromIndex: Int, toIndex: Int, percent: CGFloat) {
        if let fromView = getTabItemView(index: fromIndex){
            let fromItem = tabbarItems[fromIndex]
            fromView.label.textColor = getColorOf(percent: percent, between: fromItem.titleColor, and: fromItem.selectedTitleColor)
            fromView.image.alpha = percent
            fromView.selectImage.alpha = 1-percent
        }
        let toView = getTabItemView(index: toIndex)
        if let toView = toView{
            let toItem = tabbarItems[toIndex]
            toView.label.textColor = getColorOf(percent: percent, between: toItem.selectedTitleColor, and: toItem.titleColor)
            toView.image.alpha = 1-percent
            toView.selectImage.alpha = percent
        }
        let tWidth = trackView.width
        var trackwidth = tWidth
        if trackWidthType == .title_image,let toView = toView{
            trackwidth = toView.label.width + kImageSpacingX + toView.image.width
        }
        let itemWidth = self.itemWidth
        let sWidth = (itemWidth - trackView.width)/2
        let fromX =  CGFloat(fromIndex)*(sWidth*2+tWidth)+sWidth
        let trackX:CGFloat = toIndex > fromIndex ?
            fromX + (tWidth+2*sWidth)*percent*CGFloat(toIndex-fromIndex) :
            fromX - (tWidth+2*sWidth)*percent*CGFloat(fromIndex-toIndex)
        UIView.animate(withDuration: 0.3) {
            self.trackView.x = trackX + (tWidth-trackwidth)/2
            self.trackView.width = trackwidth
        }
        switch type {
        case .fixed:
            break
        case .scroll( _):
            let offsetX = itemWidth*CGFloat(toIndex) - scrollView.width/2
            scrollView.scrollRectToVisible(CGRect(x: offsetX, y: 0, width: scrollView.width, height: scrollView.height), animated: true)
            break
        }
    }
    
    private var itemWidth:CGFloat{
        switch type {
        case .fixed:
            return  self.width / CGFloat(tabbarItems.count)
        case .scroll(let itemWidth):
            return itemWidth
        }
    }
    private lazy var scrollView = UIScrollView(frame: self.bounds)
    private lazy var backgroundView = UIImageView(frame: self.bounds)
    private lazy var trackView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        addSubview(backgroundView)
        addSubview(scrollView)
        scrollView.addSubview(trackView)
        trackView.layer.cornerRadius = 2
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        scrollView.addGestureRecognizer(tap)
    }
    
    @objc private func  tapAction(_ tap:UITapGestureRecognizer){
        let point = tap.location(in: scrollView)
        selectedIndex = Int(point.x/itemWidth)
        delegate?.tabbar(self, selectAt: selectedIndex)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = self.bounds
        scrollView.frame = self.bounds
        layoutTabbar()
    }
    
    private func layoutTabbar(){
        if tabbarItems.count == 0{return}
        let width:CGFloat = itemWidth
        for index in 0..<tabbarItems.count{
            if let item = getTabItemView(index: index){
                item.back.frame = CGRect(x: width*CGFloat(index), y: 0, width: width, height: height)
                item.label.x = (width - (item.label.width + item.image.width + kImageSpacingX))/2
                item.label.y = (height-item.label.height)/2
                item.image.x = item.label.x + item.label.width + kImageSpacingX
                item.image.y = (height-item.image.height)/2
                item.selectImage.frame = item.image.frame
            }
        }
        let x = width*CGFloat(selectedIndex)
        if trackWidthType == .title_image,let selectItem = getTabItemView(index: selectedIndex) {
            let trackWidth = selectItem.label.width + kImageSpacingX + selectItem.image.width
            trackView.frame = CGRect(x: x + (width - trackWidth)/2, y: height - trackHeight, width: trackWidth, height: trackHeight)
        }else{
            trackView.frame = CGRect(x: x, y: height - trackHeight, width: width, height: trackHeight)
        }
    }
    private func getTabItemView(index:Int)->(back:UIView,label:UILabel,image:UIImageView,selectImage:UIImageView)?{
        if let backview = scrollView.viewWithTag(kTabItemTagBase+index){
            return (backview,backview.subviews[0] as! UILabel, backview.subviews[1] as! UIImageView,backview.subviews[2] as! UIImageView)
        }
        return nil
    }
    
}
