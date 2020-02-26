//
//  PeerProvider.swift
//  seacat
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation


class PeerProvider {
/*
    static let authorizedPeersDir = "authorized_peers"
    
    var peerCertificatesCache:[String:SecCertificate] = [:]
    
     private func getPeerCertificateFromMemCache(identity:String) -> SecCertificate? {
         guard let peer_certificate = self.peerCertificatesCache[identity] else { return nil }
         guard SeaCatValidate(certificate: peer_certificate, identity:identity) else { return nil }
         return peer_certificate
     }

     private func storePeerCertificateToMemCache(certificate:SecCertificate) {
         guard let identity = SeaCatIdentity(certificate: certificate) else { return }
         self.peerCertificatesCache[identity] = certificate
     }

     
     private func loadPeerCertificateFromDirCache(identity:String) -> SecCertificate? {
         let fileUrl = self.appdir.appendingPathComponent("certificates/\(identity).cert")
         do {
             let data = try Data(contentsOf: fileUrl)
             guard let peer_certificate = SecCertificateCreateWithData(nil, data as CFData) else { return nil }
             guard self.validate(certificate: peer_certificate, identity:identity) else { return nil }
             
             storePeerCertificateToMemCache(certificate: peer_certificate)
             return peer_certificate

         } catch { return nil }
     }
     
     private func storePeerCertificateToDirCache(certificate:SecCertificate) {
         guard let identity = SeaCatIdentity(certificate: certificate) else { return }
         let data = SecCertificateCopyData(certificate) as Data
         var fileUrl = self.appdir.appendingPathComponent("certificates/\(identity).cert")
         do {
             try data.write(to: fileUrl)
             
             var resourceValues = URLResourceValues()
             resourceValues.isExcludedFromBackup = true
             try fileUrl.setResourceValues(resourceValues)

         } catch {
             print("Failed to write to the file: \(error)")
         }
         storePeerCertificateToMemCache(certificate: certificate)
     }


     private func downloadPeerCertificate(identity:String, completion:@escaping (SecCertificate?)->()) {
         let url = SeaCat.getURL.appendingPathComponent("/"+identity)
         
         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         
         URLSession.shared.dataTask(with: request) {
             data, response, error in
             if error != nil {
                 print("Error when obtaining a peer certificate: \(error!)")
                 return completion(nil)
             }
             guard let httpResponse = response as? HTTPURLResponse else { return }
             if httpResponse.statusCode != 200 {
                 print("HTTP Eerror when obtaining a peer certificate: \(httpResponse.statusCode)")
                 return completion(nil)
             }
             
             guard let peer_certificate = SecCertificateCreateWithData(nil, data! as CFData) else {
                 print("Failed to parse peer certificate!")
                 return completion(nil)
             }
             
             guard self.validate(certificate: peer_certificate, identity:identity) else {
                 return completion(nil)
             }
             
             return completion(peer_certificate)
         }.resume()
     }
    
     
     func fetchPeerCertificate(identity:String, completion:@escaping (SecCertificate?)->()) {
         var peer_certificate:SecCertificate?
         
         peer_certificate = getPeerCertificateFromMemCache(identity: identity)
         if peer_certificate != nil { return completion(peer_certificate) }

         peer_certificate = loadPeerCertificateFromDirCache(identity: identity)
         if peer_certificate != nil { return completion(peer_certificate) }

         downloadPeerCertificate(identity: identity) {
             peer_certificate in
             guard let peer_certificate = peer_certificate else {  return completion(nil) }
             self.storePeerCertificateToDirCache(certificate: peer_certificate)
             return completion(peer_certificate)
         }
     }
     
     
     func getPeerCertificate(identity:String) -> SecCertificate? {
         var certificate:SecCertificate?
         
         certificate = getPeerCertificateFromMemCache(identity: identity)
         if certificate != nil { return certificate }

         certificate = loadPeerCertificateFromDirCache(identity: identity)
         if certificate != nil { return certificate }

         let semaphore = DispatchSemaphore(value: 0)

         downloadPeerCertificate(identity: identity) {
             peer_certificate in
             certificate = peer_certificate
             if peer_certificate != nil {
                 self.storePeerCertificateToDirCache(certificate: peer_certificate!)
             }
             semaphore.signal()
         }

         let timeout = DispatchTime.now() + .seconds(5)
         _ = semaphore.wait(timeout: timeout)

         return certificate
     }
     

     func authorize(
         peer_identity: String,
         peer_label: String? = nil,
         sign:((Data) throws -> (Data))? = nil, // Specify a function that provides a signature
         completion:@escaping (Bool)->()
     ) {
         fetchPeerCertificate(identity: peer_identity) {
             peer_certificate in
             if peer_certificate == nil {
                 completion(false)
                 return
             }
             
             //TODO: Validate the certificate
             let peer_label_r:String = peer_label != nil ? peer_label! : SecCertificateCopySubjectSummary(peer_certificate!)! as String

             let authpeersdir = self.appdir.appendingPathComponent(SeaCat.authorizedPeersDir, isDirectory: true)
             try! FileManager.default.createDirectory(at: authpeersdir, withIntermediateDirectories: true, attributes: nil)

             do {
                 let tbsdict:[String:Any] = [
                     "identity": peer_identity,
                     "label": peer_label_r,
                 ]
                 let tbsdata = try NSKeyedArchiver.archivedData(withRootObject: tbsdict, requiringSecureCoding: false)
                 
                 var dict:[String:Any] = [
                     "signed": tbsdata,
                 ]
                 if sign != nil {
                     dict["signature"] = try sign!(SeaCatSHA256(data:tbsdata))
                 }

                 let data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
                 
                 // Save to file and exclude that from a backup
                 var fileUrl = authpeersdir.appendingPathComponent(peer_identity, isDirectory:false)
                 try data.write(to: fileUrl)
                 var resourceValues = URLResourceValues()
                 resourceValues.isExcludedFromBackup = true
                 try fileUrl.setResourceValues(resourceValues)
                 
             } catch {
                 print("Failed to serialize the peer pairing info: \(error)")
                 completion(false)
                 return
             }

             completion(true)
         }
     }
     
     func unauthorize(peer_identity:String) {
         let authpeersdir = self.appdir.appendingPathComponent(SeaCat.authorizedPeersDir, isDirectory: true)
         do {
             try FileManager.default.removeItem(at: authpeersdir.appendingPathComponent(peer_identity, isDirectory:false))
         } catch {
             print("Error when removing a paired file: \(error)")
         }
     }
     
     func isAuthorized(
         verify:((_ data:Data, _ signature:Data) throws -> (Bool))? = nil,
         peer_identity:String
     ) -> Bool {
         let authpeersdir = self.appdir.appendingPathComponent(SeaCat.authorizedPeersDir, isDirectory: true)
         guard let dict = loadAuthorizedPeer(fileUrl: authpeersdir.appendingPathComponent(peer_identity), verify: verify) else { return false }
         
         guard let peer_identity = dict["identity"] as! String? else { return false }
         guard let peer_certificate = self.getPeerCertificate(identity: peer_identity) else { return false }

         //TODO: Validate the certificate ...

         return true
     }

     func enumerateAuthorizedPeers(
         verify:((_ data:Data, _ signature:Data) throws -> (Bool))? = nil,
         each: @escaping (_ identity:String, _ label:String, _ certificate:SecCertificate)->()
     ) {
         let authpeersdir = self.appdir.appendingPathComponent(SeaCat.authorizedPeersDir, isDirectory: true)
         let enumerator:FileManager.DirectoryEnumerator = FileManager.default.enumerator(at: authpeersdir, includingPropertiesForKeys: nil)!
         for fileUrl in enumerator.allObjects as! [URL] {
             
             //TODO: regular expression to validate a peer name
             
             // Parse the signed content
             guard let dict = loadAuthorizedPeer(fileUrl: fileUrl, verify: verify) else { continue }
             guard let peer_identity = dict["identity"] as! String? else { continue }
             guard let peer_label = dict["label"] as! String? else { continue }
             
             self.fetchPeerCertificate(identity: peer_identity) {
                 peer_certificate in
                 if peer_certificate == nil { return }
                 each(peer_identity, peer_label, peer_certificate!)
             }
         }
     }
     
     private func loadAuthorizedPeer(
         fileUrl: URL,
         verify:((_ data:Data, _ signature:Data) throws -> (Bool))?
     ) -> [String:Any]? {

         // Load the data
         guard let data = NSData.init(contentsOf: fileUrl) else { return nil }
         guard let signeddict = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as? [String:Any] else {
             return nil
         }
         
         // Verify a signature
         guard let signed = signeddict["signed"] else { return nil }

         if (verify != nil) {
             guard let signature = signeddict["signature"] else { return nil }
             do {
                 let verified = try verify!(
                     SeaCatSHA256(data: signed as! Data),
                     signature as! Data
                 )
                 if (!verified) {
                     print("Verification of the peer authorization failed!")
                     return nil
                 }
             } catch {
                 return nil
             }
         }
         
         // Parse the signed content
         guard let dict = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(signed as! Data) as? [String:Any] else { return nil }
         return dict
     }
*/
}
