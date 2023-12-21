//
//  MiniASN1_Parser.swift
//  SeaCat
//
//  Created by Ales Teska on 19.12.2023.
//  Copyright © 2023 TeskaLabs. All rights reserved.
//

import Foundation

func parseASN1SEQUENCE(input: Data) -> Data? {
    // Check if the first byte is 0x30 (ASN.1 sequence identifier)
    if input[0] != 0x30 { return nil }
    
    let lengthByte = input[1]
    var sequenceLength: Int
    var startIndex: Data.Index

    if lengthByte <= 0x7F {
        // Length is directly encoded in a single byte
        sequenceLength = Int(lengthByte)
        startIndex = 2 // The sequence starts right after the length byte
    } else {
        // Length is encoded in multiple bytes
        let lengthByteCount = Int(lengthByte & 0x7F) // Number of bytes used for the length
        guard input.count >= 2 + lengthByteCount else { return nil } // Check for sufficient data length

        let lengthBytes = input[2..<2+lengthByteCount]
        sequenceLength = Int(lengthBytes.reduce(0) { ($0 << 8) + Int($1) })
        startIndex = 2 + lengthByteCount // The sequence starts after the length bytes
    }

    let endIndex = startIndex + sequenceLength // End index of the sequence
    guard endIndex <= input.count else { return nil } // Check for sufficient data length

    return Data(input[startIndex..<endIndex])
}


func parseASN1Item(input: Data) -> (Data, Data)? {

    let lengthByte = input[1]
    var sequenceLength: Int
    var startIndex: Data.Index

    if lengthByte <= 0x7F {
        // Length is directly encoded in a single byte
        sequenceLength = Int(lengthByte)
        startIndex = 2 // The sequence starts right after the length byte
    } else {
        // Length is encoded in multiple bytes
        let lengthByteCount = Int(lengthByte & 0x7F) // Number of bytes used for the length
        guard input.count >= 2 + lengthByteCount else { return nil } // Check for sufficient data length

        let lengthBytes = input[2..<2+lengthByteCount]
        sequenceLength = Int(lengthBytes.reduce(0) { ($0 << 8) + Int($1) })
        startIndex = 2 + lengthByteCount // The sequence starts after the length bytes
    }

    let endIndex = startIndex + sequenceLength // End index of the sequence
    guard endIndex <= input.count else { return nil } // Check for sufficient data length

    return (Data(input[0..<endIndex]), Data(input[endIndex..<input.count]))
}

func parseASN1UTCTime(_ data: Data) -> Date? {
    guard let timeString = String(data: data[2..<data.count], encoding: .ascii) else { return nil }

    let utcTimeFormatter = DateFormatter()
    utcTimeFormatter.dateFormat = "yyMMddHHmmss'Z'"
    utcTimeFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    return utcTimeFormatter.date(from: timeString)
}
