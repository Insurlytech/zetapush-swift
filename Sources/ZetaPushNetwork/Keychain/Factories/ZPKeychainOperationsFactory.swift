//
//  ZPKeychainOperationsFactory.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 24/12/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainOperationsFactory {
  static func createAttributes(to operation: ZPKeychainOperationType, _ item: ZPKeychainItem) -> CFDictionary {
    switch item {
//    case let .password(account, service):
//      return ZPKeychainPasswordAttributesFactory.createAttributes(for: operation, associtedTo: account, and: service.rawValue)
    case let .sandboxId(label, server), let .token(label, server), let .publicToken(label, server):
      return ZPKeychainPasswordAttributesFactory.createAttributes(for: operation, associatedTo: label, and: server)
    }
  }
  
  static func createQuery(to operation: ZPKeychainOperationType, _ item: ZPKeychainItem) -> CFDictionary {
    switch item {
//    case let .password(account, service):
//      return ZPKeychainPasswordQueryFactory.createQuery(for: operation, associtedTo: account, and: service.rawValue)
    case let .sandboxId(label, server), let .token(label, server), let .publicToken(label, server):
      return ZPKeychainPasswordQueryFactory.createQuery(for: operation, associatedTo: label, and: server)
    }
  }
}
