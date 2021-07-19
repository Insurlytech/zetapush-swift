//
//  ZPKeychainDAOFactory.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 12/11/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainDAOFactory {
  static func createDAO() -> ZPKeychainDAO {
    let operations = ZPKeychainOperations()
    return ZPKeychainDAO(operations: operations)
  }
}
