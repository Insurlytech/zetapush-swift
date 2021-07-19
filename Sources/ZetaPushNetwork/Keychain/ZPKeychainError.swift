//
//  ZPKeychainError.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 12/11/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainError: Error {
  /// Error with the keychain creting and checking
  case creating
  /// Error for operation
  case operation
  /// Error for conversation String/Data
  case conversion
}
