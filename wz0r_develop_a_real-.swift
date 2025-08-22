// wz0r_develop_a_real-.swift

import UIKit
import CoreBluetooth

// Define IoT device constants
let IOT_DEVICE_NAME = "WZ0R_IoT_Device"
let IOT_DEVICE_UUID = "34FA5829-5A21-49F4-BF3F-4C3259739141"

// Define IoT device services and characteristics
let IOT_DEVICE_SERVICE_UUID = "34FA5829-5A21-49F4-BF3F-4C3259739142"
let IOT_DEVICE_TEMPERATURE_CHARACTERISTIC_UUID = "34FA5829-5A21-49F4-BF3F-4C3259739143"
let IOT_DEVICE_HUMIDITY_CHARACTERISTIC_UUID = "34FA5829-5A21-49F4-BF3F-4C3259739144"

// Define IoT dashboard view controllers
class IoTDeviceDashboardViewController: UIViewController {
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    var centralManager: CBCentralManager!
    var iotDevice: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

// Define CBCentralManagerDelegate methods
extension IoTDeviceDashboardViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [CBUUID(string: IOT_DEVICE_SERVICE_UUID)])
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        iotDevice = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        iotDevice.delegate = self
        iotDevice.discoverServices([CBUUID(string: IOT_DEVICE_SERVICE_UUID)])
    }
}

// Define CBPeripheralDelegate methods
extension IoTDeviceDashboardViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == CBUUID(string: IOT_DEVICE_SERVICE_UUID) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: IOT_DEVICE_TEMPERATURE_CHARACTERISTIC_UUID) {
            temperatureLabel.text = "\(characteristic.value?.bytes)"
        } else if characteristic.uuid == CBUUID(string: IOT_DEVICE_HUMIDITY_CHARACTERISTIC_UUID) {
            humidityLabel.text = "\(characteristic.value?.bytes)"
        }
    }
}