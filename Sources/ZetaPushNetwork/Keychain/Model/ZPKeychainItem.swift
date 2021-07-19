//
//  ZPKeychainItem.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 24/12/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainItem {
  // kSecClassGenericPassword
  // For a keychain item of class kSecClassGenericPassword, the primary key is the combination of kSecAttrAccount and kSecAttrService.
  // In other words, the tuple allows you to uniquely identify a generic password in the Keychain.
//  case password(account: String, service: ZPKeychainService)
  // You can add other items like : kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity, ...
  
  case sandboxId(label: String, server: String)
  case token(label: String, server: String)
  case publicToken(label: String, server: String)
}
