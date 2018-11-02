//
//  LocationDataManager.swift
//  GPXCreator
//
//  Created by user on 2018/11/01.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit
import CoreLocation

// 使用するエラー
enum MyError:Error {
    case fileEmpty
    case timerRun
}

class LocationDataManager: NSObject,CLLocationManagerDelegate {

    // デリゲート
    var delegate:LocationDataManagerDelegate? = nil
    
    // 位置情報マネージャ
    var locationManager:CLLocationManager!
    
    // 緯度
    var latitude:CLLocationDegrees? = nil
    // 経度
    var longitude:CLLocationDegrees? = nil
    
    // XMLテキスト(GPX)
    var xmlText:String = ""
    

    
    // 定期的に緯度経度を記録するためのタイマー
    weak var timer:Timer?
    
    override init() {
        super.init()
        // 位置情報マネージャを作る
        self.locationManager = CLLocationManager()
        // delegateにセット
        locationManager.delegate = self
    }
    
    func requestAuth() {
        // 位置情報の要求
        locationManager.requestAlwaysAuthorization()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
        
        // XMLヘッダと作成者名を入れる（ヒアドキュメントの書式です)
        self.xmlText = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <gpx version="1.1" creator="GPXCreator">
        """
        
        // 定期処理を作る
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            
            // 位置情報を取得する
            guard let latitude = self.latitude, let longitude = self.longitude else {
                // まだ取得できていない場合は終わり
                return
            }
            
            // 改行と緯度経度を文字列にして追記する
            self.xmlText.append("\n<wpt lat=\"\(latitude)\" lon=\"\(longitude)\"></wpt>")
        })
    }
    
    func stop() {
        // 位置情報停止
        locationManager.stopUpdatingLocation()
        
        // 停止時の処理
        xmlText =  xmlText + "\n</gpx>"
        
        // タイマー停止
        timer?.invalidate()
    }
    
    // ファイル保存、例外は呼び出し元に処理させる
    func save() throws -> String {
        
        if xmlText.isEmpty {
            throw MyError.fileEmpty
        }
        
        if timer != nil {
            throw MyError.timerRun
        }
        
        // ファイル保存位置の作成
        let doucumentDirURLArray = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirURL = doucumentDirURLArray.first!
        
        // 日付でファイル名を作る
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let name = dateFormatter.string(from: Date())
        // ファイル名としてパスに連結
        let filePath = documentDirURL.appendingPathComponent(name).appendingPathExtension("gpx")
        
        // 書き込みをする（例外処理のあるメソッドを使う)
        try xmlText.write(to: filePath, atomically: true, encoding: .utf8)
        
        print("ターミナルで確認するファイル位置",filePath.path)
        
        // ファイル名を返す
        return filePath.lastPathComponent
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    // 権限の変化
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // デリゲートがいるなら伝える
        self.delegate?.changeAuthorizationStatus(status: status)
    }
    
    // 位置情報が変わった
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("位置変わった",Date())
        
        // 最新の結果を得る
        let location = locations.last!
        
        // 緯度の保存
        self.latitude = location.coordinate.latitude
        // 経度の保存
        self.longitude = location.coordinate.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報がらみのerrorですよ",error.localizedDescription)
    }
}
