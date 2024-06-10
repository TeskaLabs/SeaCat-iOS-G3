//
//  CertValidity.swift
//  SeaCat
//
//  Created by Ales Teska on 10.06.2024.
//  Copyright © 2024 TeskaLabs. All rights reserved.
//

import Foundation

func getCertificateValidity(_ certificate: SecCertificate ) -> (notBefore: Date, notAfter: Date)? {
    // Parse notBefore and notAfter from the certificate
    let data = SecCertificateCopyData(certificate) as Data
    
    guard let tbsCertificate = parseASN1SEQUENCE(input: data) else {
        return nil
    }

    guard let body = parseASN1SEQUENCE(input: tbsCertificate) else {
        return nil;
    }
    
    guard let (_, d1) = parseASN1Item(input: body) else {
        return nil;
    }
    
    guard let (_, d2) = parseASN1Item(input: d1) else {
        return nil;
    }

    guard let (_, d3) = parseASN1Item(input: d2) else {
        return nil;
    }

    guard let (_, d4) = parseASN1Item(input: d3) else {
        return nil;
    }

    guard let (validitySeq, _) = parseASN1Item(input: d4) else {
        return nil;
    }

    guard let validity = parseASN1SEQUENCE(input: validitySeq) else {
        return nil;
    }

    guard let (notBeforeData, d5) = parseASN1Item(input: validity) else {
        return nil;
    }

    guard let (notAfterData, _) = parseASN1Item(input: d5) else {
        return nil;
    }

    guard let notBefore = parseASN1UTCTime(notBeforeData) else {
        return nil;
    }

    guard let notAfter = parseASN1UTCTime(notAfterData) else {
        return nil;
    }
    
    return (notBefore, notAfter)
}
