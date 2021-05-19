//
//  iPhoneBLEManager.swift
//  BLERandomNumberSender
//
//  Created by Osamu HIraoka on 2021/05/19.
//

import Foundation
import CoreBluetooth

// MARK: - iPhone BLE Service
struct DeviceBLEService {
    
    static let serviceUuid = CBUUID(string: "E2E965C1-649A-4BC0-ADF0-AD64536334D0")
    static let charateristicUuid = CBUUID(string: "A6475135-E473-402B-BC2D-E4377F15F07A")
    
    static var advertisementData: [String: Any] {
        [CBAdvertisementDataLocalNameKey: "Test Sensor Device",
         CBAdvertisementDataServiceUUIDsKey: [serviceUuid]]
    }
}

// MARK: - Device BLE Manager class
class DeviceBLEManager: NSObject {
                
    var peripheralManager: CBPeripheralManager!
    var service: CBMutableService!
    var characteristic: CBMutableCharacteristic!
        
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        service = CBMutableService(type: DeviceBLEService.serviceUuid, primary: true)
        
        characteristic = CBMutableCharacteristic(type: DeviceBLEService.charateristicUuid,
                                                  properties: .read.union(.notify),
                                                  value: nil,
                                                  permissions: .readable)
    }
    
    func startAdvertising() {
        peripheralManager.startAdvertising(DeviceBLEService.advertisementData)
    }
    
    func stopAdvertising() {
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
        }
    }
    
    func updateValuesBy(_ value: String) {
        if peripheralManager.isAdvertising {
            guard let data = value.data(using: .utf8)
            else { return }
            self.characteristic.value = data
            peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
            print("Updated value:", value)
        } else {
            print("Device BLE update is not ready")
        }
    }
}

// MARK: - CBPeripheral manager delegate
extension DeviceBLEManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Device is powered on")
            self.service.characteristics = [characteristic]
            peripheralManager.add(service)
        } else {
            print("Device is not powered on:", peripheral.state)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("failure to add service:", error.localizedDescription)
        } else {
            print("Success to add service!")
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("failure to start advertising:", error.localizedDescription)
        } else {
            print("Success to start advertising!")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        if request.characteristic.uuid.isEqual(DeviceBLEService.charateristicUuid) {
            request.value = self.characteristic.value
            self.peripheralManager.respond(to: request, withResult: CBATTError.success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Subscribe to:", characteristic.uuid)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("Stop subscribing")
    }
}
