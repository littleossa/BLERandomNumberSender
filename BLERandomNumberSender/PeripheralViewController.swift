//
//  ViewController.swift
//  BLERandomNumberSender
//
//  Created by Osamu HIraoka on 2021/05/19.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {
    
    @IBOutlet weak var serviceUuidLabel: UILabel!
    @IBOutlet weak var characteristicUuidLabel: UILabel!
    @IBOutlet weak var randomNumberLabel: UILabel!
    @IBOutlet weak var stopAdvertisingButton: UIButton!
    
    var deviceBLEManager: DeviceBLEManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceBLEManager = DeviceBLEManager()
        serviceUuidLabel.text = DeviceBLEService.serviceUuid.uuidString
        characteristicUuidLabel.text = DeviceBLEService.charateristicUuid.uuidString
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deviceBLEManager.stopAdvertising()
    }
    
    // MARK: - IBAction Button methods
   
    @IBAction func randomNumberUpdate(_ sender: UIButton) {
        let randomNumber = Int.random(in: 1...100)
        let randomNumberString = String(randomNumber)
        randomNumberLabel.text = randomNumberString
        deviceBLEManager.updateValuesBy(randomNumberString)
    }
    
    @IBAction func startAdvertising(_ sender: UIButton) {
        deviceBLEManager.startAdvertising()
    }
    
    @IBAction func stopAdvertising(_ sender: UIButton) {
        deviceBLEManager.stopAdvertising()
    }
}
