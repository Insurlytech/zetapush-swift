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
  private let keychain = ZPKeychainDAOFactory.createDAO()
  
  // MARK: Lifecycle
  public init(apiUrl: String? = nil, sandboxId: String, weakDeploymentId: String, simpleDeploymentId: String, timeout: TimeInterval?, logLevel: XCGLogger.Level = .severe, recorder: ZetapushNetworkRecorder?) {
    self.weakDeploymentId = weakDeploymentId
    self.simpleDeploymentId = simpleDeploymentId
    
    // Get the stored tokens
    ZetaPushSmartClient.migrateUserDefaultToKeychainIfNeeded(keychain: keychain)
    
    let storedSandboxId = try? keychain.get(item: .sandboxId(label: ZetaPushDefaultKeys.sandboxId, server: ZetaPushDefaultConfig.apiUrl))
    
    var stringToken = ""
    var stringPublicToken = ""
    
    if storedSandboxId == sandboxId {
      if let storedToken = try? keychain.get(item: .token(label: ZetaPushDefaultKeys.token, server: ZetaPushDefaultConfig.apiUrl)) {
        stringToken = storedToken
      }
      
      if let storedPublicToken = try? keychain.get(item: .publicToken(label: ZetaPushDefaultKeys.publicToken, server: ZetaPushDefaultConfig.apiUrl)) {
        stringPublicToken = storedPublicToken
      }
    }
    
    let serverConfiguration = ServerConfiguration(
      serverUrl: apiUrl ?? ZetaPushDefaultConfig.apiUrl,
      sandboxId: sandboxId,
      timeout: timeout ?? ZetaPushDefaultConfig.timeout
    )
    
    if !stringPublicToken.isEmpty {
      // The user is weakly authenticated and the token must be present
      
      super.init(
        serverConfiguration: serverConfiguration,
        authentication: Authentication.weak(
          stringToken,
          deploymentId: weakDeploymentId
        ),
        logLevel: logLevel,
        recorder: recorder
      )
      if storedSandboxId == sandboxId {
        self.token = stringToken
        self.publicToken = stringPublicToken
      }
    } else {
      if !stringToken.isEmpty {
        // The user is strongly (with a simple authent) authenticated and the token is present
        super.init(
          serverConfiguration: serverConfiguration,
          authentication: Authentication.simple(
            stringToken,
            password: "",
            deploymentId: simpleDeploymentId
          ),
          logLevel: logLevel,
          recorder: recorder
        )
        
        if storedSandboxId == sandboxId {
          self.token = stringToken
        }
      } else {
        // The use is not authenticated, we connect him with a weak authent
        super.init(
          serverConfiguration: serverConfiguration,
          authentication: Authentication.weak(
            "",
            deploymentId: weakDeploymentId
          ),
          logLevel: logLevel,
          recorder: recorder
        )
      }
    }
  }
  
  public convenience init(sandboxId: String, apiUrl: String? = nil, timeout: TimeInterval? = nil, logLevel: XCGLogger.Level = .severe, recorder: ZetapushNetworkRecorder?) {
    self.init(apiUrl: apiUrl, sandboxId: sandboxId, weakDeploymentId: ZetaPushDefaultConfig.weakDeploymentId, simpleDeploymentId: ZetaPushDefaultConfig.simpleDeploymentId, timeout: timeout, logLevel: logLevel, recorder: recorder)
  }
  
  override func storeHandshakeToken(_ authenticationDict: NSDictionary) {
    log.debug(#function)
    
    try? keychain.set(value: self.getSandboxId(), item: .sandboxId(label: ZetaPushDefaultKeys.sandboxId, server: ZetaPushDefaultConfig.apiUrl))
    if let token = authenticationDict["token"] as? String {
      try? keychain.set(value: token, item: .token(label: ZetaPushDefaultKeys.token, server: ZetaPushDefaultConfig.apiUrl))
      authentication.update(token: token)
    }
    if let publicToken = authenticationDict["publicToken"] as? String  {
      try? keychain.set(value: publicToken, item: .publicToken(label: ZetaPushDefaultKeys.publicToken, server: ZetaPushDefaultConfig.apiUrl))
    }
  }
  
  override func eraseHandshakeToken() {
    log.debug(#function)
    
    try? keychain.deleteAll(from: .sandboxId(label: ZetaPushDefaultKeys.sandboxId, server: ZetaPushDefaultConfig.apiUrl))
    try? keychain.deleteAll(from: .token(label: ZetaPushDefaultKeys.token, server: ZetaPushDefaultConfig.apiUrl))
    try? keychain.deleteAll(from: .publicToken(label: ZetaPushDefaultKeys.publicToken, server: ZetaPushDefaultConfig.apiUrl))
    
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
  
  private static func migrateUserDefaultToKeychainIfNeeded(keychain: ZPKeychainDAO) {
    let userDefaults = UserDefaults.standard

    guard !userDefaults.bool(forKey: ZetaPushDefaultKeys.isTokensMigratedToKeychain) else {
      return
    }
    
    // put all three in keychain if it's exist to migrate from userDefault to Keychain
    if let storedSandboxId = userDefaults.string(forKey: ZetaPushDefaultKeys.sandboxId) {
      try? keychain.set(value: storedSandboxId, item: .sandboxId(label: ZetaPushDefaultKeys.sandboxId, server: ZetaPushDefaultConfig.apiUrl))
    }
    if let storedToken = userDefaults.string(forKey: ZetaPushDefaultKeys.token) {
      try? keychain.set(value: storedToken, item: .token(label: ZetaPushDefaultKeys.token, server: ZetaPushDefaultConfig.apiUrl))
    }
    if let storedPublicToken = userDefaults.string(forKey: ZetaPushDefaultKeys.publicToken) {
      try? keychain.set(value: storedPublicToken, item: .publicToken(label: ZetaPushDefaultKeys.publicToken, server: ZetaPushDefaultConfig.apiUrl))
    }
    
    // Erase tokens from userDefaults
    userDefaults.removeObject(forKey: ZetaPushDefaultKeys.sandboxId)
    userDefaults.removeObject(forKey: ZetaPushDefaultKeys.token)
    userDefaults.removeObject(forKey: ZetaPushDefaultKeys.publicToken)

    userDefaults.set(true, forKey: ZetaPushDefaultKeys.isTokensMigratedToKeychain)
  }
}
