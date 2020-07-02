//
//  HomeKitDecoder.swift
//  Apple-BLE-Decoder
//
//  Created by Alex - SEEMOO on 09.03.20.
//

import Foundation

public extension AppleBLEDecoding {
    struct HomeKitDecoder: AppleBLEDecoder {
        public var decodableType: UInt8 {0x06}
        
        public func decode(_ data: Data) throws -> [String : DecodedEntry] {
            guard data.count >= 12 else {throw Error.incorrectLength}
            
            var i = data.startIndex
            var describingDict = [String: DecodedEntry]()
            
            let status = data[i]
            describingDict["status"] = DecodedEntry(value: status, byteRange: i...i)
            i+=1
            
            let deviceId = data[i..<i+6]
            describingDict["deviceId"] = DecodedEntry(value: deviceId, byteRange: i...i+5)
            i+=6
            
            let category = data[i..<i+2]
            describingDict["category"] = DecodedEntry(value: category, byteRange: i...i+1)
            i+=2
            
            let stateNumber = data[i..<i+2]
            describingDict["globalStateNumber"] = DecodedEntry(value: stateNumber.uint16, byteRange: i...i+1)
            i+=2
            
            let configNumber = data[i]
            describingDict["configNumber"] = DecodedEntry(value: configNumber, byteRange: i...i)
            i+=1
            
            let compatibleversion = data[i]
            describingDict["compatibleVersion"] = DecodedEntry(value: compatibleversion, byteRange: i...i)
            
            return describingDict
        }
        
        
    }
}
