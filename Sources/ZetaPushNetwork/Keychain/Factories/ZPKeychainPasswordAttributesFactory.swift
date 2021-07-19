//
//  ZPKeychainPasswordAttributesFactory.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 24/12/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainPasswordAttributesFactory {
  /// Create attributes for Keychain operations of type kSecClassInternetPassword
  /// - Parameters:
  ///   - operation: Refer to KeychainOperation (add, update, retrieve, ...)
  ///   - label: Associated label to the token (ex: publicToken)
  ///   - server: Associated service to the password (ex: ng.zetapush.com)
  static func createAttributes(for operation: ZPKeychainOperationType, associatedTo label: String, and server: String) -> CFDictionary {
    switch operation {
    case .add(let data):
      return createAttributes(toAdd: data, associatedTo: label, and: server)
    case .update(let data):
      return createAttributes(toUpdate: data)
    case .retrieve, .delete, .deleteAll, .exists:
      return NSDictionary()
    }
  }
  
  private static func createAttributes(toAdd value: Data, associatedTo label: String, and server: String) -> CFDictionary {
    [
      kSecClass: kSecClassInternetPassword,
      kSecAttrServer: server,
      kSecValueData: value
    ] as NSDictionary
  }
  
  private static func createAttributes(toUpdate value: Data) -> CFDictionary { [kSecValueData: value] as NSDictionary }
  
  private static func createAttributesToUpdateData(associatedTo label: String, and server: String) -> CFDictionary {
    [
      kSecClass: kSecClassInternetPassword,
      kSecAttrServer: server,
      kSecAttrLabel: label
    ] as NSDictionary
  }
}
