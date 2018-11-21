//
//  ViewController.swift
//  TabSliderDemo
//
//  Created by jun on 2018/11/21.
//  Copyright © 2018 ayzk. All rights reserved.
//

import UIKit

class ViewController: UIViewController,TabSlideViewDelegate {
    
    /// 每一个tab的控制器
    ///
    /// - Parameters:
    ///   - tabSlide: 滑动容器
    ///   - index: 第几个tab
    /// - Returns:
    func tabSlide(_ tabSlide: TabSlideView, controllerAt index: Int) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = random
        return vc
    }
    
    private lazy var tabSlideView = TabSlideView(trackWidth: .title_image)
    override func viewDidLoad() {
        super.viewDidLoad()
        //父控制器
        tabSlideView.baseController = self
        //代理
        tabSlideView.delegate = self
        //tab与容器间距离
        tabSlideView.tabbarBottomSpacing = 0
        //顶部tab的滑动类型（固定/滑动）
        tabSlideView.tabbarType = .scroll(itemWidth: 85)
        //tab列表
        tabSlideView.tabbarItems = ["品牌教育","名师团","美容小窍门","类1","类1","类1","类1","类1","类1"].map({TabSlideItem(title: $0)})
        ///必须先设置tabbarItems 在进行设置selectedIndex
        tabSlideView.selectedIndex = 0
        navigationItem.title = "demo"
    }
    override func loadView() {
        super.loadView()
        view.addSubview(tabSlideView)
        tabSlideView.frame = CGRect(x: 0, y: 44, width: view.width, height: view.height)
    }
    /// 随机色
    var random: UIColor {
        get{
            return UIColor(red: CGFloat(arc4random_uniform(255)) / 255.0,
                           green: CGFloat(arc4random_uniform(255)) / 255.0,
                           blue: CGFloat(arc4random_uniform(255)) / 255.0,
                           alpha: 1)
        }
    }

}

