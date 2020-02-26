//
//  Base32.swift
//  seacat
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation

// RFC 4648/3548
let alphabetEncodeTable: [Int8] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","2","3","4","5","6","7"].map { (c: UnicodeScalar) -> Int8 in Int8(c.value) }

func base32encode(_ data: UnsafeRawPointer, _ length: Int, _ table: [Int8] = alphabetEncodeTable) -> String {
    if length == 0 {
        return ""
    }
    var length = length
    
    var bytes = data.assumingMemoryBound(to: UInt8.self)
    
    let resultBufferSize = Int(ceil(Double(length) / 5)) * 8 + 1    // need null termination
    let resultBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: resultBufferSize)
    var encoded = resultBuffer
    
    // encode regular blocks
    while length >= 5 {
        encoded[0] = table[Int(bytes[0] >> 3)]
        encoded[1] = table[Int((bytes[0] & 0b00000111) << 2 | bytes[1] >> 6)]
        encoded[2] = table[Int((bytes[1] & 0b00111110) >> 1)]
        encoded[3] = table[Int((bytes[1] & 0b00000001) << 4 | bytes[2] >> 4)]
        encoded[4] = table[Int((bytes[2] & 0b00001111) << 1 | bytes[3] >> 7)]
        encoded[5] = table[Int((bytes[3] & 0b01111100) >> 2)]
        encoded[6] = table[Int((bytes[3] & 0b00000011) << 3 | bytes[4] >> 5)]
        encoded[7] = table[Int((bytes[4] & 0b00011111))]
        length -= 5
        encoded = encoded.advanced(by: 8)
        bytes = bytes.advanced(by: 5)
    }
    
    // encode last block
    var byte0, byte1, byte2, byte3, byte4: UInt8
    (byte0, byte1, byte2, byte3, byte4) = (0,0,0,0,0)
    switch length {
    case 4:
        byte3 = bytes[3]
        encoded[6] = table[Int((byte3 & 0b00000011) << 3 | byte4 >> 5)]
        encoded[5] = table[Int((byte3 & 0b01111100) >> 2)]
        fallthrough
    case 3:
        byte2 = bytes[2]
        encoded[4] = table[Int((byte2 & 0b00001111) << 1 | byte3 >> 7)]
        fallthrough
    case 2:
        byte1 = bytes[1]
        encoded[3] = table[Int((byte1 & 0b00000001) << 4 | byte2 >> 4)]
        encoded[2] = table[Int((byte1 & 0b00111110) >> 1)]
        fallthrough
    case 1:
        byte0 = bytes[0]
        encoded[1] = table[Int((byte0 & 0b00000111) << 2 | byte1 >> 6)]
        encoded[0] = table[Int(byte0 >> 3)]
    default: break
    }
    
    // padding
    let pad = Int8(UnicodeScalar("=").value)
    switch length {
    case 0:
        encoded[0] = 0
    case 1:
        encoded[2] = pad
        encoded[3] = pad
        fallthrough
    case 2:
        encoded[4] = pad
        fallthrough
    case 3:
        encoded[5] = pad
        encoded[6] = pad
        fallthrough
    case 4:
        encoded[7] = pad
        fallthrough
    default:
        encoded[8] = 0
        break
    }
    
    // return
    if let base32Encoded = String(validatingUTF8: resultBuffer) {
        #if swift(>=4.1)
        resultBuffer.deallocate()
        #else
        resultBuffer.deallocate(capacity: resultBufferSize)
        #endif
        return base32Encoded
    } else {
        #if swift(>=4.1)
        resultBuffer.deallocate()
        #else
        resultBuffer.deallocate(capacity: resultBufferSize)
        #endif
        fatalError("internal error")
    }
}
