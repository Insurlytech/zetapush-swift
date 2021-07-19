//
//  ZPKeychainItem.swift
//  LeoCare
//
//  Created by Anthony Guiguen on 24/12/2020.
//  Copyright © 2020 Leocare. All rights reserved.
//

import Foundation

enum ZPKeychainItem {  
  case sandboxId(label: String, server: String)
  case token(label: String, server: String)
  case publicToken(label: String, server: String)
}
