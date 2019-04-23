//
//  ZetaPushClient+Handshake.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation

/*
 Handle Simple, Weak and Delegating authentication for ZetaPush
 */

// MARK: - AuthentType
enum AuthentType: String {
  case Auth_File = "file"
  case Auth_Simple = "simple"
  case Auth_Weak = "weak"
  case Auth_Delegating = "delegating"
}

// MARK: - AbstractHandshake
open class AbstractHandshake {
  // MARK: Properties
  var deploymentId = ""
  var authType = ""
  
  // MARK: LifeCycle
  public init (authType: String, deploymentId: String){
    self.authType = authType
    self.deploymentId = deploymentId
  }
  
  // MARK: Methods
  func getHandshakeFields(_ client: ClientHelper) -> [String: Any] {
    var auth = [String: Any]()
    auth["type"] =  client.getSandboxId() + "." + deploymentId + "." + getAuthType()
    auth["version"] = getAuthVersion()
    auth["data"] = getAuthData()
    auth["resource"] = client.getResource()
    return auth
  }
  
  func getAuthType() -> String {
    return authType
  }
  
  func getAuthVersion() -> String {
    return "none"
  }
  
  func getAuthData() -> [String: Any] {
    var dict = [String: Any]()
    dict["error"] = "method must be overridden"
    return dict
  }
}

// MARK: - TokenHandshake
open class TokenHandshake: AbstractHandshake {
  // MARK: Properties
  fileprivate var token = ""
  
  // MARK: Lifecycle
  public init(token: String, deploymentId: String, authType: String) {
    super.init(authType: authType, deploymentId: deploymentId)
    self.token = token
  }
  
  override func getAuthData() -> [String: Any] {
    var dict = [String: Any]()
    dict["token"] = self.token
    return dict
  }
}

// MARK: - CredentialsHanshake
open class CredentialsHanshake: AbstractHandshake {
  // MARK: Properties
  fileprivate var login: String = ""
  fileprivate var password : String = ""
  
  // MARK: Lifecycle
  public init(login: String, password: String, deploymentId: String, authType: String) {
    super.init(authType: authType, deploymentId: deploymentId)
    self.login = login
    self.password = password
  }
  
  override func getAuthData() -> [String: Any] {
    var dict = [String: Any]()
    dict["login"] = login
    dict["password"] = password
    return dict
  }
}

// MARK: - Authentication
public enum Authentication {
  static func createHandshake(_ login: String, password: String, deploymentId: String, authType: String) -> AbstractHandshake {
    if password.isEmpty {
      return TokenHandshake(token: login, deploymentId: deploymentId, authType: authType)
    } else {
      return CredentialsHanshake(login: login, password: password, deploymentId: deploymentId, authType: authType)
    }
  }
  
  static func simple(_ login: String, password: String, deploymentId: String) -> AbstractHandshake {
    return createHandshake(login, password: password, deploymentId: deploymentId, authType: AuthentType.Auth_Simple.rawValue)
  }
  
  static func weak(_ token: String, deploymentId: String) -> AbstractHandshake {
    return createHandshake(token, password: "", deploymentId: deploymentId, authType: AuthentType.Auth_Weak.rawValue)
  }
  
  static func delegating(_ token: String, deploymentId: String) -> AbstractHandshake {
    return createHandshake(token, password: "", deploymentId: deploymentId, authType: AuthentType.Auth_Delegating.rawValue)
  }
}
