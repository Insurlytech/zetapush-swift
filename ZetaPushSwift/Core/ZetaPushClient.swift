//
//  ZetaPushClient.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import Gloss

enum zetaPushDefaultConfig {
  static let apiUrl = "https://api.zpush.io"
  static let weakDeploymentId = "weak_0"
  static let simpleDeploymentId = "simple_0"
  static let macroDeployementId = "macro_0"
  static let resourceLength = 8
}
enum zetaPushDefaultKeys{
  static let sandboxId = "zetapush.sandboxId"
  static let token = "zetapush.token"
  static let publicToken = "zetapush.publicToken"
  static let resource = "zetapush.resource"
}

public typealias ZPChannelSubscriptionBlock = (Glossy) -> Void
public typealias ZPMacroServiceErrorBlock = (_ zetaPushMacroService: ZetaPushMacroService, _ zetapushMacroError: ZetaPushMacroError) -> Void
public typealias ZPServiceErrorBlock = (_ zetaPushService: ZetaPushService, _ zetapushServiceError: ZetaPushServiceError) -> Void

/*
 Generic (useless) client for ZetaPush
 Use Weak or Smart client instead
 */
// MARK: - ZetaPushClient
open class ZetaPushClient: ClientHelper { }

// MARK: - ZPMessage
open class ZPMessage {
  // MARK: Lifecycle
  required public init () { }
  
  open func toDict() -> NSDictionary {
    preconditionFailure("This method must be overridden")
  }
  
  open func fromDict(_ dict: NSDictionary) {
    preconditionFailure("This method must be overridden")
  }
}

// MARK: - ZetaPushUtils
public enum ZetaPushUtils {
  static func generateResourceName() -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<zetaPushDefaultConfig.resourceLength).compactMap{ _ in letters.randomElement() })
  }
}
