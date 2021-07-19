//
//  ZPKeychainOperations.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 12/11/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

protocol ZPKeychainOperationsContract {
  /// Funtion to add an item to keychain
  ///  - parameters:
  ///  - data: Data to save
  ///  - item: Associated Keychain Item
  func add(data: Data, for item: ZPKeychainItem) throws
  
  /// Function to update an item to keychain
  ///  - parameters:
  ///  - data: Data to replace for
  ///  - item: Associated Keychain Item
  func update(data: Data, for item: ZPKeychainItem) throws
  /// Function to retrieve an item to keychain
  ///  - parameters:
  ///  - item: Associated Keychain Item
  func retreive(item: ZPKeychainItem) throws -> Data?
  
  /// Function to check if we've an existing a keychain `item`
  ///  - parameters:
  ///  - item: Associated Keychain Item
  ///  - returns: Boolean type with the answer if the keychain item exists
  func exists(item: ZPKeychainItem) throws -> Bool
  
  /// Function to delete a single item
  ///  - parameters:
  ///  - item: Associated Keychain Item
  func delete(item: ZPKeychainItem) throws
  
  /// Function to delete all items for the app
  ///  - parameters:
  ///  - item: Associated Keychain Item
  func deleteAll(item: ZPKeychainItem) throws
}

class ZPKeychainOperations: ZPKeychainOperationsContract {
  // MARK: Methods
  func add(data: Data, for item: ZPKeychainItem) throws {
    let attributes = ZPKeychainOperationsFactory.createAttributes(to: .add(data), item)
    let status = SecItemAdd(attributes, nil)
    guard status == errSecSuccess else { throw ZPKeychainError.operation }
  }
  
  func update(data: Data, for item: ZPKeychainItem) throws {
    let operation: ZPKeychainOperationType = .update(data)
    let query = ZPKeychainOperationsFactory.createQuery(to: operation, item)
    let attributes = ZPKeychainOperationsFactory.createAttributes(to: operation, item)
    let status = SecItemUpdate(query, attributes)
    guard status == errSecSuccess else { throw ZPKeychainError.operation }
  }
  
  func retreive(item: ZPKeychainItem) throws -> Data? {
    var result: AnyObject?
    let query = ZPKeychainOperationsFactory.createQuery(to: .retrieve, item)
    let status = SecItemCopyMatching(query, &result)
    
    switch status {
    case errSecSuccess:
      return result as? Data
    case errSecItemNotFound:
      return nil
    default:
      throw ZPKeychainError.operation
    }
  }
  
  func delete(item: ZPKeychainItem) throws {
    let query = ZPKeychainOperationsFactory.createQuery(to: .delete, item)
    let status = SecItemDelete(query)
    guard status == errSecSuccess else { throw ZPKeychainError.operation }
  }
  
  func deleteAll(item: ZPKeychainItem) throws {
    let query = ZPKeychainOperationsFactory.createQuery(to: .deleteAll, item)
    let status = SecItemDelete(query)
    guard status == errSecSuccess else { throw ZPKeychainError.operation }
  }
  
  func exists(item: ZPKeychainItem) throws -> Bool {
    let query = ZPKeychainOperationsFactory.createQuery(to: .exists, item)
    let status = SecItemCopyMatching(query, nil)
    
    switch status {
    case errSecSuccess:
      return true
    case errSecItemNotFound:
      return false
    default:
      throw ZPKeychainError.creating
    }
  }
}
