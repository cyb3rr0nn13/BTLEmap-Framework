//
//  TLV.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 02.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation


struct TLV {
    let type: UInt
    let length: UInt
    let value: Data
}

extension TLV {

struct TLVBox {
    var tlvs: [TLV]
    
    /// Can be 8, 16, 32, 64 and defines the size of type and lenght in bits
    var tlvSize = Size.tlv8
    
    private var tlvByteSize: Int {
        return tlvSize.rawValue/8
    }
    
    init() {
        tlvs = []
    }
    
    init(tlvs: [TLV]) {
        self.tlvs = tlvs
    }
    
    mutating func addValue(withType type: TLVType, andLength length: UInt, andValue value: Data) {
        let tlv = TLV(type: type.uInt, length: length, value: value)
        
        self.tlvs.append(tlv)
    }
    
    mutating func addInt(withType type: TLVType, andValue value: UInt8) {
        var val = value
        let dataNum = Data(bytes: &val, count: MemoryLayout.size(ofValue: val))
        
        self.addValue(withType: type, andLength: UInt(MemoryLayout.size(ofValue: value)), andValue: dataNum)
    }
    
    
    /// Get a normal dictionary from the TLV files
    ///
    /// - Returns: Dictionary with TLV types as index and the data value
    func toDictionary() -> [UInt : Data] {
        var dict = [UInt : Data]()
        
        tlvs.forEach({dict[$0.type] = $0.value})
        
        return dict
    }
    
    /// Serialize the TLV to a bytes buffer
    ///
    /// - Returns: Data containing the serialized TLV
    func serialize() throws -> Data {
        var serialized = Data()

        tlvs.forEach { (tlv) in
            serialized.append(self.tlvSize.toData(tlv.type))
            serialized.append(self.tlvSize.toData(tlv.length))
            serialized.append(tlv.value)
        }
        
        return serialized
    }
    
    
    /// Get the TLV value for a specific type
    ///
    /// - Parameter type: a tlv type
    /// - Returns: The assigned value if one is assigned
    func getValue(forType type: TLVType) -> Data? {
        let tlv = tlvs.first(where: {$0.type == type.uInt})
        
        return tlv?.value
    }
    
    func getTypes() -> [UInt] {
        return tlvs.map({$0.type})
    }
    
 
    /// Deserialize a binary TLV to a TLVBox struct.
    ///
    /// - Parameter data: that contains serialized TLV
    /// - Returns: TLVBox that contains all parsed TLVs
    /// - Throws: TLVError if parsing fails
    static func deserialize(fromData data: Data, withSize size: TLV.Size, bigEndian:Bool=false) throws -> TLVBox {
        
        var index: Data.Index = data.startIndex
        var box = TLVBox()
        
        //Iterate over the bytes until every TLV is parsed
        while index < data.endIndex {
            //Get type and length
            guard var type = data[index..<index.advanced(by: size.bytes)].uint else {throw Error.parsingFailed}
            index = index.advanced(by: size.bytes)
            guard var length = data[index..<index.advanced(by: size.bytes)].uint else {throw Error.parsingFailed}
            index = index.advanced(by: size.bytes)
            
            if bigEndian {
                type = UInt(bigEndian: type)
                length = UInt(bigEndian: length)
            }
            
            //Get the index of the end of value data
            let valueEndIndex = index.advanced(by: Int(length))
            
            guard valueEndIndex <= data.endIndex else {throw Error.parsingFailed}
            
            let value = data[index..<valueEndIndex]
            
            let tlv  = TLV(type: UInt(type), length: length, value: value)
            box.tlvs.append(tlv)
            
            index = valueEndIndex
        }
        
        
        return box
    }

}
}


extension TLV {
    enum Error: Swift.Error {
        case serializationPointerFailed
        case parsingFailed
    }

    enum Size: Int {
        case tlv8 = 8
        case tlv16 = 16
        case tlv32 = 32
        case tlv64 = 64
        
        var bytes: Int {
            return self.rawValue/8
        }
        
        func toData(_ uint: UInt) -> Data {
            switch self {
            case .tlv8:
                return UInt8(uint).data
            case .tlv16:
                return UInt16(uint).data
            case .tlv32:
                return UInt32(uint).data
            case .tlv64:
                return UInt64(uint).data
            }
        }
    }
}

protocol TLVType {
    var uInt: UInt { get }
}
