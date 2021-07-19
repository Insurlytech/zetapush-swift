//
//  ZPKeychainDAO.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 12/11/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

final class ZPKeychainDAO {
  // MARK: Properties
  private let operations: ZPKeychainOperationsContract
  
  // MARK: Lifecycle
  init(operations: ZPKeychainOperationsContract) {
    self.operations = operations
  }
  
  // MARK: Methods
  /// Function to store a keychain item
  ///  - parameters:
  ///  - value: String to store in keychain
  ///  - element: stored element
  func set(value: String, item: ZPKeychainItem) throws {
    guard let data = value.data(using: .utf8) else { throw ZPKeychainError.conversion }
    
    // If the value exists `update the value`
    if try operations.exists(item: item) {
      try operations.update(data: data, for: item)
    } else {
      // Just insert
      try operations.add(data: data, for: item)
    }
  }
  
  /// Function to retrieve an item in ´Data´ format (If not present, returns nil)
  ///  - parameters:
  ///  - element: stored element
  ///  - returns: String from stored item
  func get(item: ZPKeychainItem) throws -> String? {
    if try operations.exists(item: item) {
      guard let data = try operations.retreive(item: item) else { return nil }
      guard let string = String(data: data, encoding: .utf8) else { throw ZPKeychainError.conversion }
      return string
    } else {
      throw ZPKeychainError.operation
    }
  }
  
  /// Function to delete a single item
  ///  - parameters:
  ///  - element: stored element
  func delete(item: ZPKeychainItem) throws {
    if try operations.exists(item: item) {
      return try operations.delete(item: item)
    } else {
      throw ZPKeychainError.operation
    }
  }
  
  /// Function to delete all items
  func deleteAll(from item: ZPKeychainItem) throws {
    try operations.deleteAll(item: item)
  }
}
