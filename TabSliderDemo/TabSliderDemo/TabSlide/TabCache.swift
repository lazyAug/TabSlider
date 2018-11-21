//
//  TabCache.swift
//  LadyBand
//
//  Created by jun on 2018/9/14.
//  Copyright © 2018年 com.ladyband. All rights reserved.
//

import UIKit

class TabCache: NSObject {
    private  var capacity = 0
    private lazy var dic = [String:AnyObject]()
    private lazy var dicKeys = [String]()
    
    init(count:Int) {
        super.init()
        self.capacity = count
    }
    func set(object:AnyObject,forKey key:String) {
        if let index = dicKeys.index(of: key){
            dicKeys.remove(at: index)
            dicKeys.append(key)
            dic[key] = object
            return
        }
        if dic.count >= capacity{
            let first = dicKeys.first!
            dic.removeValue(forKey: first)
            dicKeys.removeFirst()
        }
        dic[key] = object
        dicKeys.append(key)
    }
    func object(forKey key:String)->AnyObject?{
        if let index = dicKeys.index(of: key){
            dicKeys.remove(at: index)
            dicKeys.append(key)
        }
        return dic.first(where: {$0.key == key})?.value
    }
    
}
