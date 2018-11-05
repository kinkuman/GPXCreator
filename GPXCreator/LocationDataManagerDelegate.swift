//
//  LocationDataManagerDelegate.swift
//  GPXCreator
//
//  Created by user on 2018/11/01.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit
import CoreLocation

// 位置情報データマネージャデリゲート
protocol LocationDataManagerDelegate: NSObjectProtocol {

    // 権限状況の変化があったら呼ばれる
    func changeAuthorizationStatus(status:CLAuthorizationStatus)
    
}
