//
//  ViewController.swift
//  GPXCreator
//
//  Created by user on 2018/11/01.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController,LocationDataManagerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var jogboyImageView: UIImageView!
    
    // 自作の位置情報データクラス
    var locationDataManager:LocationDataManager! = nil
    
    // Play/Stop切り替えよう一時ボタン置き場
    var barButtonItem:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "位置情報トラッカー"
        
        // 位置情報データマネージャ作成
        self.locationDataManager = LocationDataManager.shared
        // 自分をデリゲートにセット
        self.locationDataManager.delegate = self
        
        // 入れ替えのためのバーボタンをstoryboardが作ったものをとっておく
        barButtonItem = self.navigationItem.rightBarButtonItem
        
        // テキストビューの装飾
        self.textView.backgroundColor = UIColor.lightGray
        self.textView.textColor = UIColor.white
        
        // jogboyの準備
        jogboyImageView.animationImages = self.jogboyImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // アプリ動作中の利用を申請
        locationDataManager.requestAuth()
        
        // 通知の利用確認
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            // 結果はどうでも良い要求を出して選ばせることが重要
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - targetAction
    
    // GPS記録開始/停止
    @IBAction func playOrStop(_ sender: UIBarButtonItem) {
        
        // ナビゲーションボタンの入れ替え
        if self.navigationItem.rightBarButtonItem == self.barButtonItem {
            
            // playボタンの時はstopボタンにする
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(playOrStop(_:)))
            
            // jogboyはしり出す
            jogboyImageView.startAnimating()
            
            // 記録開始
            recording()
            
        } else {
            // stopボタンの時はplayボタンにする
            self.navigationItem.rightBarButtonItem = barButtonItem
            
            // 位置情報停止
            locationDataManager.stop()
            
            // jogboyを止める
            jogboyImageView.stopAnimating()
            
            // XMLをとりだす
            self.textView.text = locationDataManager.xmlText
        }
    }
    
    // ファイル保存
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        do{
            // 保存処理
            let fname = try locationDataManager.save()
            alert(message: "\(fname)ファイル保存しました")
        } catch MyError.fileEmpty {
            alert(message: "保存する内容がありません")
        } catch MyError.timerRun {
            alert(message: "計測が終了していません")
        } catch {
            alert(message: "ファイル保存に失敗しました")
        }
    }
    
    // MARK: - 自作デリゲート
    
    // 権限状況が変化した
    func changeAuthorizationStatus(status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways:
            print("常に使ってよし")
        case .authorizedWhenInUse:
            print("アプリ起動中は使ってよし")
        case .denied:
            print("使ってはいけない")
        case .notDetermined:
            print("まだ聞いてない")
        case .restricted:
            print("ペアレンタルコントロールなどで自由にONできない")
        }
    }
    
    // MARK: - 自作メソッド ---------------
    
    // 記録開始
    func recording() {

        // 位置情報の受信を開始
        if CLLocationManager.locationServicesEnabled() {
            locationDataManager.start()
            print("位置情報の使用を開始します")
        } else {
            print("位置情報使えない")
            alert(message: "位置情報使えません")
            return
        }
    }
    
    // 連番画像の読み込み
    func jogboyImages() -> [UIImage] {
        var theArray = Array<UIImage>()
        
        for num in 1...10 {
            let imageName = "jogboy_\(num)"
            let image = UIImage(named: imageName)!
            theArray.append(image)
        }
        
        return theArray
    }
    
    func alert(message:String) {
        let alert = UIAlertController(title: "メッセージ", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

