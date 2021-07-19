//
//  ZPKeychainPasswordQueryFactory.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 27/01/2021.
//  Copyright © 2021 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainPasswordQueryFactory {
  /// Create query for Keychain operations of type kSecClassInternetPassword
  /// - Parameters:
  ///   - operation: Refer to KeychainOperation (add, update, retrieve, ...)
  ///   - label: Associated label to the token (ex: publicToken)
  ///   - server: Associated server to the token
  static func createQuery(for operation: ZPKeychainOperationType, associatedTo label: String, and server: String) -> CFDictionary {
    switch operation {
    case .add:
      return NSDictionary()
    case .update:
      return createQueryToUpdateData(associatedTo: label, and: server)
    case .retrieve:
      return createQueryToRetrieveData(associatedTo: label, and: server)
    case .exists:
      return createQueryToCheckIfDataExists(associatedTo: label, and: server)
    case .delete:
      return createQueryToDeleteData(associatedTo: label, and: server)
    case .deleteAll:
      return createQuerytoDeleteAll()
    }
  }
  
  private static func createQueryToUpdateData(associatedTo label: String, and server: String) -> CFDictionary {
    [
      kSecClass: kSecClassInternetPassword,
      kSecAttrLabel: label,
      kSecAttrServer: server
    ] as NSDictionary
  }
  private static func createQueryToRetrieveData(associatedTo label: String, and server: String) -> CFDictionary {
    [
      kSecClass: kSecClassInternetPassword,
      kSecAttrAccount: label,
      kSecAttrServer: server,
      kSecReturnData: true
    ] as NSDictionary
  }
  private static func createQueryToCheckIfDataExists(associatedTo label: String, and server: String) -> CFDictionary {
    [
      kSecClass: kSecClassInternetPassword,
      kSecAttrAccount: label,
      kSecAttrServer: server,
      kSecReturnData: false
    ] as NSDictionary
  }
  private static func createQueryToDeleteData(associatedTo label: String, and server: String) -> CFDictionary {
    [
      kSecClass: kSecClassInternetPassword,
      kSecAttrLabel: label,
      kSecAttrServer: server
    ] as NSDictionary
  }
  private static func createQuerytoDeleteAll() -> CFDictionary { [kSecClass: kSecClassInternetPassword] as NSDictionary }
}
