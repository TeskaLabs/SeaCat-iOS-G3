//
//  MiniASN1_DER.swift
//  SeaCat
//
//  Created by Ales Teska on 18.2.19.
//  Copyright © 2019 TeskaLabs. All rights reserved.
//

import Foundation


struct MiniASN1DER {
    
    // Shall not be initialized.
    private init() {}

    
    static func intToBytes(_ x: UInt) -> [UInt8] {
        var l = x
        var d:[UInt8] = []
        while (l > 0) {
            d.insert(UInt8(l & 0xFF), at: 0)
            l = l >> 8
        }
        
        return d
    }

    
    static func il(tag: UInt8, length: UInt) -> [UInt8] {
        if (length < 128) {
            return [tag, UInt8(length)]
        }
        let d = intToBytes(length)
        
        return [tag, 0x80 | UInt8(d.count)] + d
    }
    

    static func SEQUENCE(_ elements: [[UInt8]?], implicit_tagging: Bool = true, tag:UInt8 = 0x30) -> [UInt8] {
        var d:[UInt8] = []
        
        var n: UInt8 = 0
        for e:[UInt8]? in elements {
            guard (e != nil)  else {
                n += 1
                continue
            }

            var identifier: UInt8
            if implicit_tagging {
                let e0 = e![0]
                if (((e0 & 0x1F) == 0x10) || ((e0 & 0x1F) == 0x11) || (e0 == 0xA0)) {
                    // the element is constructed
                    identifier = 0xA0
                } else {
                    // the element is primitive
                    identifier = 0x80
                }
                identifier += n
            }
            else {
                identifier = e![0]
            }

            d.append(identifier)
            d += e![1..<e!.count]
            
            n += 1
        }
        
        return il(tag:tag, length:UInt(d.count)) + d
    }
    
    static func SEQUENCE_OF(_ elements: [[UInt8]?]) -> [UInt8] {
        return SEQUENCE(elements, implicit_tagging: false)
    }

    static func SET_OF(_ elements: [[UInt8]?]) -> [UInt8] {
        return SEQUENCE(elements, implicit_tagging: false, tag:0x31)
    }

    static func INTEGER(_ value: UInt) -> [UInt8] {
        // TODO: Support for negative numbers
        if (value == 0) {
            return il(tag: 0x02, length: 1) + [0]
        }
        var b = intToBytes(value)
        if (b[0] & 0x80 == 0x80) {
            b.insert(0, at: 0)
        }
        
        return il(tag: 0x02, length: UInt(b.count)) + b
    }
    
    static func OCTET_STRING(_ value: Data) -> [UInt8] {
        return il(tag:0x04, length:UInt(value.count)) + value
    }

    static func NULL() -> [UInt8] {
        return il(tag:0x05, length:0)
    }
    
    static func IA5String(_ value: String) -> [UInt8] {
        let b = value.data(using: .ascii)!
        return il(tag:0x16, length:UInt(b.count)) + b
    }
    
    static func BIT_STRING(_ value: Data) -> [UInt8] {
        return il(tag:0x03, length:UInt(value.count)+1) + [0] + value
    }
    
    static func UTF8String(_ value: String) -> [UInt8] {
        let b = value.data(using: .utf8)!
        return il(tag:12, length:UInt(b.count)) + b
    }

    static func PrintableString(_ value: String) -> [UInt8] {
        let b = value.data(using: .ascii)!
        return il(tag:19, length:UInt(b.count)) + b
    }
    
    static func UTCTime(_ value: Date) -> [UInt8] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmssa'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // It has been reported that on some iOS devices AM/PM is still part
        // of the output even though dateFormat doesn't contain an 'a' symbol
        formatter.amSymbol = ""
        formatter.pmSymbol = ""
        
        let s = formatter.string(from: value)
        let b = s.data(using: .ascii)!
        
        return il(tag: 23, length: UInt(b.count)) + b
    }
    
    
    static func variableLengthQuantity(value: Int) -> [UInt8] {
        // Break it up in groups of 7 bits starting from the lowest significant bit
        // For all the other groups of 7 bits than lowest one, set the MSB to 1
        var v = value
        var m: UInt8 = 0x00
        var output: [UInt8] = []
        while (v >= 0x80) {
            output.insert(UInt8(v & 0x7f) | m, at:0)
            v = v >> 7
            m = 0x80
        }
        output.insert(UInt8(v) | m, at:0)
        
        return output
    }
    
    
    static func OBJECT_IDENTIFIER(_ value: String) -> [UInt8] {
        let a: [Int] = value.split(separator: ".").map { Int($0)! }
        var oid: [UInt8] = [UInt8(a[0]*40 + a[1])] // First two items are coded by a1*40+a2
        // A rest is Variable-length_quantity
        for n in a[2..<a.count] {
            oid += variableLengthQuantity(value:n)
        }
        
        return il(tag: 0x06, length: UInt(oid.count)) + oid
    }
}
