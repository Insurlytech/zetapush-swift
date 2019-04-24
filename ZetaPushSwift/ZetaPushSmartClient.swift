//
//  ZetaPushSmartClient.swift
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
// MARK: - ZetaPushSmartClient
open class ZetaPushSmartClient: ClientHelper {
  // MARK: Properties
  var login = ""
  var password = ""
  var weakDeploymentId = ""
  var simpleDeploymentId = ""
  var resourceName = ""
  
  // MARK: Lifecycle
  public init(sandboxId: String, weakDeploymentId: String, simpleDeploymentId: String, logLevel: XCGLogger.Level = .severe) {
    self.weakDeploymentId = weakDeploymentId
    self.simpleDeploymentId = simpleDeploymentId
    
    // Get the stored tokens
    let defaults = UserDefaults.standard
    let storedSandboxId = defaults.string(forKey: zetaPushDefaultKeys.sandboxId)
    
    var stringToken = ""
    var stringPublicToken = ""
    
    if storedSandboxId == sandboxId {
      if let storedToken = defaults.string(forKey: zetaPushDefaultKeys.token) {
        stringToken = storedToken
      }
      if let storedPublicToken = defaults.string(forKey: zetaPushDefaultKeys.publicToken) {
        stringPublicToken = storedPublicToken
      }
    }
    if !stringPublicToken.isEmpty {
      // The user is weakly authenticated and the token must be present
      super.init(apiUrl: zetaPushDefaultConfig.apiUrl, sandboxId: sandboxId, authentication: Authentication.weak(stringToken, deploymentId: weakDeploymentId), logLevel: logLevel)
      
      if storedSandboxId == sandboxId {
        self.token = stringToken
        self.publicToken = stringPublicToken
      }
    } else {
      if !stringToken.isEmpty {
        // The user is strongly (with a simple authent) authenticated and the token is present
        super.init(apiUrl: zetaPushDefaultConfig.apiUrl, sandboxId: sandboxId, authentication: Authentication.simple(stringToken, password:"", deploymentId: simpleDeploymentId), logLevel: logLevel)
        
        if storedSandboxId == sandboxId {
          self.token = stringToken
        }
      } else {
        // The use is not authenticated, we connect him with a weak authent
        super.init(apiUrl: zetaPushDefaultConfig.apiUrl, sandboxId: sandboxId, authentication: Authentication.weak("", deploymentId: weakDeploymentId), logLevel: logLevel)
      }
    }
  }
  
  public convenience init(sandboxId: String, logLevel: XCGLogger.Level = .severe) {
    self.init(sandboxId: sandboxId, weakDeploymentId: zetaPushDefaultConfig.weakDeploymentId, simpleDeploymentId: zetaPushDefaultConfig.simpleDeploymentId, logLevel: logLevel)
  }
  
  override func storeHandshakeToken(_ authenticationDict: NSDictionary) {
    log.debug(#function)
    let defaults = UserDefaults.standard
    defaults.set(self.getSandboxId(), forKey: zetaPushDefaultKeys.sandboxId)
    if let token = authenticationDict["token"] as? String {
      defaults.set(token, forKey: zetaPushDefaultKeys.token)
    }
    if let publicToken = authenticationDict["publicToken"] as? String  {
      defaults.set(publicToken, forKey: zetaPushDefaultKeys.publicToken)
    }
  }
  
  override func eraseHandshakeToken() {
    log.debug(#function)
    
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: zetaPushDefaultKeys.sandboxId)
    defaults.removeObject(forKey: zetaPushDefaultKeys.token)
    defaults.removeObject(forKey: zetaPushDefaultKeys.publicToken)
    
    self.token = ""
    self.publicToken = ""
  }
  
  override open func logout() {
    setAuthentication(authentication: Authentication.weak("", deploymentId: weakDeploymentId))
    super.logout()
  }
  
  open func setCredentials(login: String, password: String){
    self.login = login
    self.password = password
    let auth = Authentication.simple(login, password: password, deploymentId: simpleDeploymentId)
    setAuthentication(authentication: auth)
    
    // Delete previously stored tokens
    eraseHandshakeToken()
  }
}
