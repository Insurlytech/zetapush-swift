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
  public init(apiUrl: String? = nil, sandboxId: String, weakDeploymentId: String, simpleDeploymentId: String, timeout: TimeInterval?, logLevel: XCGLogger.Level = .severe, recorder: ZetapushNetworkRecorder?) {
    self.weakDeploymentId = weakDeploymentId
    self.simpleDeploymentId = simpleDeploymentId
    
    // Get the stored tokens
    let defaults = UserDefaults.standard
    let storedSandboxId = defaults.string(forKey: ZetaPushDefaultKeys.sandboxId)
    
    var stringToken = ""
    var stringPublicToken = ""
    
    if storedSandboxId == sandboxId {
      if let storedToken = defaults.string(forKey: ZetaPushDefaultKeys.token) {
        stringToken = storedToken
      }
      if let storedPublicToken = defaults.string(forKey: ZetaPushDefaultKeys.publicToken) {
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
    let defaults = UserDefaults.standard
    defaults.set(self.getSandboxId(), forKey: ZetaPushDefaultKeys.sandboxId)
    if let token = authenticationDict["token"] as? String {
      defaults.set(token, forKey: ZetaPushDefaultKeys.token)
      authentication.update(token: token)
    }
    if let publicToken = authenticationDict["publicToken"] as? String  {
      defaults.set(publicToken, forKey: ZetaPushDefaultKeys.publicToken)
    }
  }
  
  override func eraseHandshakeToken() {
    log.debug(#function)
    
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: ZetaPushDefaultKeys.sandboxId)
    defaults.removeObject(forKey: ZetaPushDefaultKeys.token)
    defaults.removeObject(forKey: ZetaPushDefaultKeys.publicToken)
    
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
