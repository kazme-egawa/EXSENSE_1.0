//
//  FirstViewController.swift
//  EXSENSE_1.0
//
//  Created by 江川主民 on 2017/10/31.
//  Copyright © 2017年 江川主民. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class FirstViewController: UIViewController, CBPeripheralDelegate {
    
    var isScanning = false
    var peripheral: CBPeripheral!
    var myservice: CBService!
    var settingCharacteristic: CBCharacteristic!
    var outputCharacteristic: CBCharacteristic!
    
    let target_peripheral_name = "EGABLE2D4D"
    let target_service_uuid = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000300")
    let target_charactaristic_uuid = CBUUID(string: "00035B03-58E6-07DD-021A-08123A000301")
    var response = ""
    
    let scanviewcontroller = ScanViewController();

    @IBOutlet weak var Axlabel: UILabel!
    @IBOutlet weak var Aylabel: UILabel!
    @IBOutlet weak var Azlabel: UILabel!
    @IBOutlet weak var Gxlabel: UILabel!
    @IBOutlet weak var Gylabel: UILabel!
    @IBOutlet weak var Gzlabel: UILabel!
    @IBOutlet weak var Mxlabel: UILabel!
    @IBOutlet weak var Mylabel: UILabel!
    @IBOutlet weak var Mzlabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let str = "DoFMode:on\r\n"
        let data = str.data(using: String.Encoding.utf8)
        print(data!)
//        self.peripheral = scanviewcontroller.peripheral
        print("check peripheral2")
        print(self.peripheral)
        self.peripheral.delegate = self
//        self.outputCharacteristic = scanviewcontroller.outputCharacteristic
        print("check output")
        print(self.outputCharacteristic)
        self.peripheral.writeValue(data!, for: outputCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    // MARK: CBCentralManagerDelegate
//
//    // セントラルマネージャの状態が変化すると呼ばれる
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("state: \(central.state)")
//        switch central.state {
//        case .poweredOff:
//            print("Bluetoothの電源がOff")
//        case .poweredOn:
//            print("Bluetoothの電源はOn")
//        case .resetting:
//            print("レスティング状態")
//        case .unauthorized:
//            print("非認証状態")
//        case .unknown:
//            print("不明")
//        case .unsupported:
//            print("非対応")
//        }
//    }
//
//    // ペリフェラルを発見すると呼ばれる
//    func centralManager(_ central: CBCentralManager,didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//
//        self.peripheral = peripheral
//        centralManager?.stopScan()
//
//        //接続開始
//        central.connect(peripheral, options: nil)
//    }
//
//    // ペリフェラルへの接続が成功すると呼ばれる
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("接続成功！")
//        print("BLEデバイス: \(peripheral)")
//
//        centralManager.stopScan()
//        print("スキャン終了！")
//
//        // サービス探索結果を受け取るためにデリゲートをセット
//        self.peripheral.delegate = self
//
//        // サービス探索開始
//        self.peripheral.discoverServices([target_service_uuid])
//    }
    
    
    // MARK:CBPeripheralDelegate
    
    /*
     接続先のPeripheralを設定
     */
    func setPeripheral(target: CBPeripheral) {
        self.peripheral = target
        print("target")
        print(self.peripheral)
    }
    
    /*
     Characteristicを設定
     */
    func setCharactaristic(characteristic: CBCharacteristic) {
        self.outputCharacteristic = characteristic
        print("charactristic")
        print(self.outputCharacteristic)
    }
    
    // サービス発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        guard let services = peripheral.services, services.count > 0 else {
            print("no services")
            return
        }
        print("\(services.count) 個のサービスを発見！ \(services)")
        
        for service in services {
            // キャラクタリスティックを探索開始
            self.peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        guard let characteristics = service.characteristics, characteristics.count > 0 else {
            print("no characteristics")
            return
        }
        print("\(characteristics.count) 個のキャラクタリスティックを発見！ \(characteristics)")
        
        for characteristic in characteristics where characteristic.uuid.isEqual(target_charactaristic_uuid) {
            
            outputCharacteristic = characteristic
            print("Write Indicate UUID を発見！")
            
            peripheral.readValue(for: characteristic)
            
            // 更新通知受け取りを開始する
            peripheral.setNotifyValue(true, for: characteristic)
            
            let str = "MLDPstart\r\n"
            let data = str.data(using: String.Encoding.utf8)
            peripheral.writeValue(data!, for: outputCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    // Notify開始／停止時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error.debugDescription)
        } else {
            print("Notify状態更新成功！characteristic UUID:\(characteristic.uuid), isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    // データ更新時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        let data = characteristic.value
        let dataString = String(data: data!, encoding: String.Encoding.utf8)
        
        print("データ更新！")
        
        responseCommand(str: dataString!)
    }
    
    // データ書き込みが完了すると呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("書き込み失敗...error: \(error.debugDescription), characteristic uuid: \(characteristic.uuid)")
            return
        }
        
        print("書き込み成功！service uuid: \(characteristic.service.uuid), characteristic uuid: \(characteristic.uuid)")
    }
    
    // =========================================================================
    // MARK: Actions
    func responseCommand(str: String) {
        response += str
        
        if response.contains("\r\n") {
            print(response)
            
            let dofarr = response.components(separatedBy: "\t")
            
            Axlabel.text = dofarr[0]
            Aylabel.text = dofarr[1]
            Azlabel.text = dofarr[2]
            Gxlabel.text = dofarr[3]
            Gylabel.text = dofarr[4]
            Gzlabel.text = dofarr[5]
            Mxlabel.text = dofarr[6]
            Mylabel.text = dofarr[7]
            Mzlabel.text = dofarr[8]
            
            response = ""
        }
    }

}

