//
//  StringExtension.swift
//  Alamofire
//
//  Created by Dzianis Baidan on 22.07.2020.
//

import UIKit

// MARK: -
// MARK: - Base64

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

// MARK: -
// MARK: - Crypt

extension String {
    
    func getCharAtIndex(_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
}

