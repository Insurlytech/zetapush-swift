//
//  ZetaPushClient+Helper.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import XCGLogger

/*
 Base class for managing ZetaPush connexion
 */

// MARK: - ClientHelper
open class ClientHelper: NSObject, CometdClientDelegate {
  // MARK: Properties
  var sandboxId = ""
  var server = ""
  var apiUrl = ""
  var connected = false
  var userId = ""
  var resource = ""
  var token = ""
  var publicToken = ""
  
  var firstHandshakeFlag = true
  
  var subscriptionQueue = [Subscription]()
  // Flag used for automatic reconnection
  var wasConnected = false
  // Delay in s before automatic reconnection
  var automaticReconnectionDelay = 10
  
  var logLevel: XCGLogger.Level = .severe
  
  private(set) var authentication: AbstractHandshake
  let cometdClient: CometdClient
  
  open weak var delegate: ClientHelperDelegate?
  
  let log = XCGLogger(identifier: "zetapushLogger", includeDefaultDestinations: true)
  let tags = XCGLogger.Constants.userInfoKeyTags
  public var timeout: TimeInterval = ZetapushConstants.timeout
  
  // MARK: Lifecycle
  public init(apiUrl: String, sandboxId: String, authentication: AbstractHandshake, resource: String = "", logLevel: XCGLogger.Level = .severe) {
    self.sandboxId = sandboxId
    self.authentication = authentication
    self.resource = resource
    self.apiUrl = apiUrl
    self.cometdClient = CometdClient()
    super.init()
    
    self.logLevel = logLevel
    log.setup(level: logLevel)
    
    // Handle resource
    let defaults = UserDefaults.standard
    if resource.isEmpty {
      if let storedResource = defaults.string(forKey: zetaPushDefaultKeys.resource) {
        self.resource = storedResource
      } else {
        self.resource = ZetaPushUtils.generateResourceName()
        defaults.set(self.resource, forKey: zetaPushDefaultKeys.resource)
      }
    }
    
    cometdClient.delegate = self
  }
  
  // MARK: Methods
  open func setAuthentication(authentication: AbstractHandshake) {
    self.authentication = authentication
  }
  
  /// - Parameters:
  ///   - delay: Delay in seconds
  open func setAutomaticReconnectionDelay(delay: Int) {
    automaticReconnectionDelay = delay
  }
  
  // Disconnect from server
  open func disconnect() {
    log.zp.debug("ClientHelper disconnect")
    wasConnected = false
    connected = false
    cometdClient.disconnectFromServer()
  }
  
  // Connect to server
  open func connect() {
    log.debug("Client Connection: check the validation of server url : \(server)")
    
    guard server.isEmpty else {
      log.zp.debug("Client Connection: ZetaPush configured Server")
      log.zp.debug(self.server)
      configureCometdClient()
      return
    }
    let stringUrl = self.apiUrl + "/" + sandboxId
    guard let url = URL(string: stringUrl), UIApplication.shared.canOpenURL(url) else {
      self.log.verbose("ZP server -> can't open url : " + stringUrl)
      return
    }
    
    // Check the http://api.zpush.io with sandboxId
    self.log.verbose("ZP server -> target url : " + url.description)
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      guard let self = self else { return }
      guard let data = data else {
        self.log.zp.error("Client Connection: No server for the sandbox")
        return
      }
      guard error == nil else {
        self.log.error (error!)
        return
      }
      
      self.log.verbose("ZP server -> server response data : " + data.description)
      let jsonAnyTest = try? JSONSerialization.jsonObject(with: data, options: [])
      let jsonTest = jsonAnyTest as? [String: Any] ?? [:]
      self.log.verbose("ZP server -> server response : " + jsonTest.description)
      
      guard let jsonAny = try? JSONSerialization.jsonObject(with: data, options: []),
        let json = jsonAny as? [String : Any],
        let servers = json["servers"] as? [Any] else {
          self.log.zp.error("Client Connection: Failed to parse data from server")
          return
      }
      
      guard let randomServer = servers.randomElement() as? String else {
        self.log.zp.error("Client Connection: No server in servers object")
        return
      }
      self.server = randomServer + "/strd"
      self.log.debug("Client Connection: ZetaPush selected Server")
      self.log.debug("Client Connection: server returned server url : \(self.server)")
      
      self.cometdClient.setLogLevel(logLevel: self.logLevel)
      self.configureCometdClient()
    }
    task.resume()
  }
  
  private func configureCometdClient() {
    cometdClient.configure(url: server)
    let handshakeFields = authentication.getHandshakeFields(self)
    self.log.debug("authentification = \(authentication)")
    cometdClient.connectHandshake(handshakeFields)
  }
  
  open func subscribe(_ tuples: [ModelBlockTuple]) {
    // Convert model to subscription
    let models: [CometdSubscriptionModel] = tuples.map(cometdClient.modelToSubscription)
      .filter { $0.state.isSubscribingTo }
      .compactMap { $0.state.model }
    // Batch subscriptions
    cometdClient.subscribe(models)
  }
  
  @discardableResult
  open func subscribe(_ channel: String, block: ChannelSubscriptionBlock? = nil) -> Subscription? {
    let (state, sub) = cometdClient.subscribeToChannel(channel, block: block)
    guard sub != nil else {
      log.zp.error("sub is NIL")
      log.zp.error(channel)
      return nil
    }
    if case let .subscribingTo(model) = state {
      // if channel to subscribe is in state = subscribing to we need to launch the subscription of it
      cometdClient.subscribe(model)
    }
    return sub
  }
  
  open func publish(_ channel: String, message: [String: Any]) {
    cometdClient.publish(message, channel: channel)
  }
  
  open func unsubscribe(_ subscription: Subscription) {
    log.zp.debug("ClientHelper unsubscribe")
    cometdClient.unsubscribeFromChannel(subscription)
    if let index = subscriptionQueue.firstIndex(of: subscription){
      subscriptionQueue.remove(at: index)
    }
  }
  
  open func logout() {
    log.zp.debug("ClientHelper logout")
    eraseHandshakeToken()
    disconnect()
  }
  
  open func setForceSecure(_ isSecure: Bool) {
    cometdClient.setForceSecure(isSecure)
  }
  
  open func composeServiceChannel(_ verb: String, deploymentId: String) -> String {
    return "/service/" + sandboxId + "/" + deploymentId + "/" + verb
  }
  
  open func getLogLevel() -> XCGLogger.Level {
    return logLevel
  }
  
  open func setLogLevel(logLevel: XCGLogger.Level){
    self.logLevel = logLevel
    log.setup(level: logLevel)
  }
  
  func storeHandshakeToken(_ authenticationDict: NSDictionary) {
    preconditionFailure("This method must be overridden")
  }
  
  func eraseHandshakeToken() {
    preconditionFailure("This method must be overridden")
  }
  
  open func getClientId() -> String {
    return cometdClient.getCometdClientId()
  }
  
  open func getHandshakeFields() -> [String: Any] {
    return authentication.getHandshakeFields(self)
  }
  
  open func getResource() -> String {
    return resource
  }
  
  open func getSandboxId() -> String {
    return sandboxId
  }
  
  open func getServer() -> String {
    return server
  }
  
  open func setServerUrl(_ serverUrl: String) {
    server = serverUrl
  }
  
  open func getUserId() -> String {
    return userId
  }
  
  open func isConnected() -> Bool {
    return cometdClient.isConnected()
  }
  
  open func getPublicToken() -> String {
    return publicToken
  }
  
  open func isWeaklyAuthenticated() -> Bool {
    return !publicToken.isEmpty
  }
  
  open func isStronglyAuthenticated() -> Bool {
    return !isWeaklyAuthenticated() && !token.isEmpty
  }
  
  /*
   Delegate functions from CometdClientDelegate
   */
  open func connectedToServer(_ client: CometdClient) {
    log.zp.debug("ClientHelper Connected to ZetaPush server")
    connected = true
    if !wasConnected && connected {
      delegate?.onConnectionEstablished(self)
      wasConnected = connected
    }
  }
  
  open func handshakeSucceeded(_ client: CometdClient, handshakeDict: NSDictionary) {
    log.zp.debug("ClientHelper Handshake Succeeded")
    log.zp.debug(handshakeDict)
    guard let authentication = handshakeDict["authentication"] as? NSDictionary else {
      log.zp.error("handshakeSucceeded: authentication is nil")
      return
    }
    
    if let _token = authentication["token"] as? String {
      token = _token
    }
    if let _publicToken = authentication["publicToken"] as? String {
      publicToken = _publicToken
    }
    if let _userId = authentication["userId"] as? String {
      userId = _userId
    }
    
    storeHandshakeToken(authentication)
    
    subsbribeQueuedSubscriptions()
    
    delegate?.onSuccessfulHandshake(self)
  }
  
  func subsbribeQueuedSubscriptions() {
    log.zp.debug("ClientHelper subscribe queued subscriptions")
    // Automatic resubscribe after handshake (not the first one)
    if !firstHandshakeFlag {
      let tempArray = subscriptionQueue
      subscriptionQueue.removeAll()
      tempArray.forEach({ subscribe($0.channel, block: $0.callback) })
    }
    firstHandshakeFlag = false
  }
  
  open func handshakeFailed(_ client: CometdClient) {
    log.zp.error("ClientHelper Handshake Failed")
    delegate?.onFailedHandshake(self)
  }
  
  open func connectionFailed(_ client: CometdClient) {
    log.zp.error("ClientHelper Failed to connect to Cometd server!")
    if wasConnected {
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(automaticReconnectionDelay)) { [weak self] in
        self?.connect()
      }
    }
    delegate?.onConnectionBroken(self)
  }
  
  open func disconnectedFromServer(_ client: CometdClient) {
    log.zp.debug("ClientHelper Disconnected from Cometd server")
    connected = false
    delegate?.onConnectionClosed(self)
  }
  
  open func disconnectedAdviceReconnect(_ client: CometdClient) {
    log.zp.debug("ClientHelper Disconnected from Cometd server")
    delegate?.onConnectionClosedAdviceReconnect(self)
  }
  
  open func didSubscribeToChannel(_ client: CometdClient, channel: String) {
    log.zp.debug("ClientHelper Subscribed to channel \(channel)")
    delegate?.onDidSubscribeToChannel(self, channel: channel)
  }
  
  open func didUnsubscribeFromChannel(_ client: CometdClient, channel: String) {
    log.zp.debug("ClientHelper Unsubscribed from channel \(channel)")
    delegate?.onDidUnsubscribeFromChannel(self, channel: channel)
  }
  
  open func subscriptionFailedWithError(_ client: CometdClient, error: subscriptionError) {
    log.zp.error("ClientHelper Subscription failed")
    delegate?.onSubscriptionFailedWithError(self, error: error)
  }
  
  open func messageReceived(_ client: CometdClient, messageDict: NSDictionary, channel: String) {
    log.zp.debug("ClientHelper messageReceived \(channel)")
    log.zp.debug(messageDict)
  }
}
