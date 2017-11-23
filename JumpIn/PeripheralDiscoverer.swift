//
//  PeripheralDiscoverer.swift
//  HelloBT4
//
//  Created by Anders Bogild (andb@mmmi.sdu.dk) on 06/07/16.
//

import Foundation
import CoreBluetooth
import UIKit

enum kPDNotificationType:String{
    case newPeripheralsDiscovered
    case peripheralStateChanged
    case serviceDiscovered
    case characteristicDiscovered
    case allServicesAndCharacteristicsDiscovered
    case discriptorUpdated
    case valueUpdated
}

class PeripheralDiscoverer : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var D = true
    
    //Singleton pattern, we want only one instance of this class.
    static let sharedInstance = PeripheralDiscoverer()
    
    var central:CBCentralManager?
    
    var discovered_devices:[UUID:CBPeripheral] = [:]
    
    private override init()
    {
        super.init()
        self.central = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        if(D){print("PeripheralDiscoverer.init()")}
    }
    
    // MARK: --- CBCentralManagerDelegate ---
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if(D){print("PeripheralDiscoverer: didUpdateState \(central.state)")}
        
        if (central.state == CBManagerState.poweredOn)
        {
            if(D){print("PeripheralDiscoverer: didUpdateState ON")}
            
            //Specific service
            //let MyServiceUuid = CBUUID.init(string: "7E940010-8030-4261-8523-8953AB03CFC0")
            //self.central?.scanForPeripherals(withServices:[MyServiceUuid], options: nil)
            
            //All serivces
            self.central?.scanForPeripherals(withServices:nil, options: nil)
        }
        else
        {}
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let id = peripheral.identifier //iOS abstraction over hardware address to comply with privacy of the MAC address.
        
        //Add peripheral to dict.
        self.discovered_devices[id] = peripheral
        
        if(D){print("PeripheralDiscoverer: didDiscoverPeripheral: \(id.uuidString) \(String(describing: peripheral.name))")}
        
        //Notify via NSNotification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.newPeripheralsDiscovered.rawValue), object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(D){print("PeripheralDiscoverer: didConnectPeripheral: \(peripheral.state.rawValue)")}
        
        //Notify that we are connected.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.peripheralStateChanged.rawValue), object: peripheral)
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDisconnectPeripheral: \(peripheral.state.rawValue)")}
        
        //Notify that we are disconnected.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.peripheralStateChanged.rawValue), object: peripheral)

    }
    
    
    //MARK: --- CBPeripheralDelegate ---
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverServices")}
        for service:CBService in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverCharacteristicsForService")}
        
        for c:CBCharacteristic in service.characteristics!{
            if(D){print("\(c.uuid.uuidString)")}
            
            //Notify characteristic discovered.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.characteristicDiscovered.rawValue), object: c)
            
            //Discover descriptors
            peripheral.discoverDescriptors(for:c)
        }
        
        
        //Determine if charasteristics for all services has been discovered
        var all_characteristics_discovered = true
        for s:CBService in peripheral.services!{
            if s.characteristics == nil{
                all_characteristics_discovered = false
            }
        }
        
        if all_characteristics_discovered == true {
            
            //Notify when all characteristics for all services has been fund.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.allServicesAndCharacteristicsDiscovered.rawValue), object: peripheral)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didDiscoverDescriptorsForCharacteristic \(characteristic.uuid.uuidString)")}
            
            //Read values for desctiptors
        for d in characteristic.descriptors! {
            peripheral.readValue(for:d)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForDescriptor")}
        
        //Notify about updated descriptor
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.discriptorUpdated.rawValue), object: descriptor)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateValueForCharacteristic")}
        
        //Notify about updated value
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kPDNotificationType.valueUpdated.rawValue), object: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if(D){print("PeripheralDiscoverer: didUpdateNotificationStateForCharacteristic charac=\(characteristic.uuid.uuidString) isNotifying=\(characteristic.isNotifying)")}
    }

}
