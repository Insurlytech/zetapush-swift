//
//  ZPKeychainOperationType.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 24/12/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainOperationType {
  case add(Data), update(Data), retrieve, exists, delete, deleteAll
}
