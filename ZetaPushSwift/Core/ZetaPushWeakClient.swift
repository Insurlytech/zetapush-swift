//
//  ZetaPushWeakClient.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import XCGLogger

/*
 ZetaPush Smart Client
 
 Description: autoconnect with a weak authentication
 can use credential from simple authentication
 automatic reconnection with stored token
 
 */
// MARK: - ZetaPushWeakClient
open class ZetaPushWeakClient: ClientHelper {
  // MARK: LifeCycle
  public init(sandboxId: String, weakDeploymentId: String, logLevel: XCGLogger.Level = .severe) {
    let defaults = UserDefaults.standard
    let storedSandboxId = defaults.string(forKey: zetaPushDefaultKeys.sandboxId)
    var stringToken = ""
    
    if storedSandboxId == sandboxId, let storedToken = defaults.string(forKey: zetaPushDefaultKeys.token) {
      stringToken = storedToken
    }
    
    let authentication = Authentication.weak(stringToken, deploymentId: weakDeploymentId)
    super.init(apiUrl: zetaPushDefaultConfig.apiUrl, sandboxId: sandboxId, authentication: authentication, logLevel: logLevel)
    
    if storedSandboxId == sandboxId {
      self.token = stringToken
    }
  }
  
  public convenience init(sandboxId: String, logLevel: XCGLogger.Level = .severe) {
    self.init(sandboxId: sandboxId, weakDeploymentId: zetaPushDefaultConfig.weakDeploymentId, logLevel: logLevel)
  }
  
  // MARK: Methods
  override func storeHandshakeToken(_ authenticationDict: NSDictionary) {
    log.debug ("override storeHandshakeToken")
    let defaults = UserDefaults.standard
    defaults.set(getSandboxId(), forKey: zetaPushDefaultKeys.sandboxId)
    
    if let token = authenticationDict["token"] as? String {
      defaults.set(token, forKey: zetaPushDefaultKeys.token)
    }
    if let publicToken = authenticationDict["publicToken"] as? String {
      defaults.set(publicToken, forKey: zetaPushDefaultKeys.publicToken)
    }
  }
  
  override func eraseHandshakeToken() {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: zetaPushDefaultKeys.sandboxId)
    defaults.removeObject(forKey: zetaPushDefaultKeys.token)
    defaults.removeObject(forKey: zetaPushDefaultKeys.publicToken)
  }
}
