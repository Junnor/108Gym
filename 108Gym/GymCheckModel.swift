//
//  GymCheckModel.swift
//  108Gym
//
//  Created by dq on 2018/9/28.
//  Copyright © 2018 moelove. All rights reserved.
//

import UIKit
import RealmSwift

class GymCheckModel: Object {
    
    @objc dynamic var date: TimeInterval = 0
    
    // 打卡（不一定锻炼了）
    @objc dynamic var checked = false
    
    // 锻炼（一定打卡了）
    @objc dynamic var exercise = false
    
    func primaryKey() -> String? { return "date" }

    // MARK: Helper
    
    var title: String {
        return DateFormatter.checkFMT().string(from: Date(timeIntervalSince1970: date))
    }
    
    // 返回是锻炼还是简单去打了一下卡就走了
    var detail: String {
        return exercise ? "exercise" : "check"
    }


}

extension DateFormatter {
    
    static func checkFMT() -> DateFormatter {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formmater
    }

}
