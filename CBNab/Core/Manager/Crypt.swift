//
//  Crypt.swift
//  Alamofire
//
//  Created by Cccv on 19.07.2020.
//

import UIKit

public class Crypt {
    
    private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    public init() {}
    
    public func encrypt(string: String, key: Int) -> String {
        var encrypted = ""
        
        for ch1 in string {
            if let index = alphabet.firstIndex(of: ch1) {
                var intIndex = index.utf16Offset(in: alphabet)
                intIndex -= key
                intIndex = intIndex < 0 ? alphabet.count + intIndex : intIndex
                encrypted += String(alphabet.getCharAtIndex(intIndex))
            } else {
                encrypted += String(ch1)
            }
        }
        
        return encrypted
    }
    
    public func decrypt(string: String, key: Int) -> String {
        var decrypted = ""
        
        for ch1 in string {
            if let index = alphabet.firstIndex(of: ch1) {
                var intIndex = index.utf16Offset(in: alphabet)
                intIndex += key
                intIndex = intIndex >= alphabet.count ? intIndex - alphabet.count : intIndex
                decrypted += String(alphabet.getCharAtIndex(intIndex))
            } else {
                decrypted += String(ch1)
            }
        }
        
        return decrypted
    }
    
}
