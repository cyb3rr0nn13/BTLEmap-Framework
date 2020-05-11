//
//  HCIPackets.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation


public struct HCI_EventAdvertisementResponse {
    let eventCode: UInt8 = 0x3E
    let parameterTotalLength: UInt8 = 1
    let subEventCode: UInt8 = 0x02
    let numberOfReports: UInt8 = 1
    let eventType: AdvertisementType
    let addressType: BLE_AddressType
    let address: Data
    let lengthData: UInt8
    let data: Data
    let rssi: Int8
    
    let bytes: Data
    
    // Packet structure
    // | Event Code (1byte) | ParameterTotalLength (1byte) | subEventCode (1byte) | numberOfReports (1byte) | event Type (1byte) | address type (1byte) | address (6bytes) | length (1 byte) | advertisement data (x bytes) | rssi |
    
    init(eventType: AdvertisementType, addressType: BLE_AddressType, address: Data, data: Data, rssi: Int8) {
        self.eventType = eventType
        self.addressType = addressType
        self.data = data
        self.rssi = rssi
        self.lengthData = UInt8(data.count)
        self.address = address
        
        //Construct HCI packet
        var bytes = Data()
        bytes.append(eventCode)
        bytes.append(parameterTotalLength)
        bytes.append(subEventCode)
        bytes.append(numberOfReports)
        bytes.append(eventType.rawValue)
        bytes.append(addressType.rawValue)
        bytes.append(address)
        bytes.append(self.lengthData)
        bytes.append(data)
        var rssiBytes = rssi
        bytes.append(Data(bytes: &rssiBytes, count: MemoryLayout.size(ofValue: rssiBytes)))
        
        self.bytes = bytes
    }
    
    // This initializer is used for packets where the address is unknown
    init(eventType: AdvertisementType, addressType: BLE_AddressType, addressUUID: UUID, data: Data, rssi: Int8) {
        var addressUUIDBytes = addressUUID.uuid
        let generatedAddress = Data(bytes: &addressUUIDBytes, count: MemoryLayout.size(ofValue: addressUUIDBytes))[0..<6]
        self.init(eventType: eventType, addressType: addressType, address: generatedAddress, data: data, rssi: rssi)
    }
    
    /// Generate a MAC address like 6 bytes from a UUID
    /// - Returns: The first 6 bytes of a uuid
    static func uuidToMacAddress(uuid: UUID) -> Data {
        var addressUUIDBytes = uuid.uuid
        let generatedAddress = Data(bytes: &addressUUIDBytes, count: MemoryLayout.size(ofValue: addressUUIDBytes))[0..<6]
        return generatedAddress
    }
}


struct UART_HCI_Packet {
    enum HCI_PacketType: UInt8 {
        case command = 0x01
        case aclData = 0x02
        case synchronousData = 0x03
        case event = 0x04
    }
    
    var bytes: Data
    
    init(hciPacketType: HCI_PacketType, hciPacket: Data) {
        self.bytes = Data([hciPacketType.rawValue]) + hciPacket
    }
}
