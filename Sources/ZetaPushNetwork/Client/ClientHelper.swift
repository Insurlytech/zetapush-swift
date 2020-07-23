//
//  ZetaPushClient+Helper.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import CometDClient
import Foundation
import XCGLogger
import UIKit

/*
 Base class for managing ZetaPush connexion
 */

// MARK: - ClientHelper
open class ClientHelper: NSObject {
  // MARK: Properties
  let serverConfiguration: ServerConfiguration
  private let remote: ServerRemoteDataSource
  var server = ""
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
  let cometdClient: CometdClientContract
  
  open weak var delegate: ClientHelperDelegate?
  
  let log = XCGLogger(identifier: "zetaPushLogger", includeDefaultDestinations: true)
  let tags = XCGLogger.Constants.userInfoKeyTags
  
  // MARK: Lifecycle
  public init(serverConfiguration: ServerConfiguration, authentication: AbstractHandshake, resource: String = "", logLevel: XCGLogger.Level = .severe) {
    self.serverConfiguration = serverConfiguration
    self.remote = ServerRemoteDataSource(configuration: serverConfiguration)
    self.authentication = authentication
    self.resource = resource
    self.cometdClient = CometdClient()
    super.init()
    
    self.logLevel = logLevel
    log.setup(level: logLevel)
    self.cometdClient.log.outputLevel = self.logLevel
    
    // Handle resource
    let defaults = UserDefaults.standard
    if resource.isEmpty {
      if let storedResource = defaults.string(forKey: ZetaPushDefaultKeys.resource) {
        self.resource = storedResource
      } else {
        self.resource = ZetaPushUtils.generateResourceName()
        defaults.set(self.resource, forKey: ZetaPushDefaultKeys.resource)
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
    log.zp.debug("ZetaPushNetwork try to connect")
    
    guard server.isEmpty else {
      log.zp.debug("ZetaPushNetwork already has a server url")
      configureCometdClient()
      return
    }
    
    log.zp.debug("ZetaPushNetwork try to fetch servers URLs")
    remote.fetchServersURLs { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let servers):
        self.log.zp.debug("ZetaPushNetwork succeded to fetch servers URLs : \(servers)")
        guard let randomServer = servers.randomElement() else { return }
        self.log.zp.debug("ZetaPushNetwork select a random server : \(randomServer)")
        self.server = randomServer + "/strd"
        
        self.configureCometdClient()
      case .failure(let error):
        self.log.zp.error("ZetaPushNetwork failed to fetch servers URLs : \(error.localizedDescription)")
        self.delegate?.onConnectionFailed(self, error: .connectionFailed(error: error))
      }
    }
  }
  
  private func configureCometdClient() {
    log.zp.debug("ZetaPushNetwork configure CometdClient")
    cometdClient.configure(url: server)
    let handshakeFields = authentication.getHandshakeFields(self)
    log.zp.debug("authentification = \(authentication)")
    cometdClient.handshake(fields: handshakeFields)
  }
  
  open func subscribe(_ tuples: [ModelBlockTuple]) {
    // Convert model to subscription
    let models: [CometdSubscriptionModel] = tuples.map(cometdClient.transformModelBlockToSubscription(modelBlock:))
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
    return "/service/" + serverConfiguration.sandboxId + "/" + deploymentId + "/" + verb
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
    return cometdClient.clientId ?? ""
  }
  
  open func getHandshakeFields() -> [String: Any] {
    return authentication.getHandshakeFields(self)
  }
  
  open func getResource() -> String {
    return resource
  }
  
  open func getSandboxId() -> String {
    return serverConfiguration.sandboxId
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
    return cometdClient.isConnected
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
}

extension ClientHelper: CometdClientDelegate {
  // MARK: CometdClientDelegate
  public func didReceiveMessage(dictionary: NSDictionary, from channel: String, client: CometdClientContract) {
    log.zp.debug("ClientHelper messageReceived \(channel)")
    log.zp.debug(dictionary)
  }
  
  public func didReceivePong(from client: CometdClientContract) {
    log.zp.debug("ClientHelper pongReceived")
  }
  
  public func didConnected(from client: CometdClientContract) {
    log.zp.debug("ClientHelper Connected to ZetaPush server")
    connected = true
    if !wasConnected && connected {
      delegate?.onConnectionEstablished(self)
      wasConnected = connected
    }
  }
  
  public func handshakeDidSucceeded(dictionary: NSDictionary, from client: CometdClientContract) {
    log.zp.debug("ClientHelper Handshake Succeeded")
    log.zp.debug(dictionary)
    guard let authentication = dictionary["authentication"] as? NSDictionary else {
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

  public func handshakeDidFailed(error: CometDClientError, from client: CometdClientContract) {
    log.zp.error("ClientHelper Handshake Failed")
    delegate?.onFailedHandshake(self, error: .handshakeFailed(error: error))
  }
  
  public func didDisconnected(error: CometDClientError?, from client: CometdClientContract) {
    log.zp.debug("ClientHelper Disconnected from Cometd server")
    connected = false
    if let error = error {
      delegate?.onConnectionClosed(self, error: .connectionClosed(error: error))
    } else {
      delegate?.onConnectionClosed(self, error: nil)
    }
  }
  
  public func didAdvisedToReconnect(from client: CometdClientContract) {
    log.zp.debug("ClientHelper Disconnected from Cometd server")
    delegate?.onConnectionClosedAdviceReconnect(self)
  }
  
  public func didLostConnection(error: CometDClientError, from client: CometdClientContract) {
    log.zp.error("ClientHelper lost connection")
    if wasConnected {
      DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(automaticReconnectionDelay)) { [weak self] in
        self?.connect()
      }
    }
    delegate?.onConnectionBroken(self, error: .connectionBroken(error: error))
  }
  
  public func didSubscribeToChannel(channel: String, from client: CometdClientContract) {
    log.zp.debug("ClientHelper Subscribed to channel \(channel)")
    delegate?.onDidSubscribeToChannel(self, channel: channel)
  }
  
  public func didUnsubscribeFromChannel(channel: String, from client: CometdClientContract) {
    log.zp.debug("ClientHelper Unsubscribed from channel \(channel)")
    delegate?.onDidUnsubscribeFromChannel(self, channel: channel)
  }
  
  public func subscriptionFailedWithError(error: CometDClientError, from client: CometdClientContract) {
    log.zp.error("ClientHelper Subscription failed")
    delegate?.onSubscriptionFailedWithError(self, error: .subscription(error: error))
  }
  
  public func didWriteError(error: CometDClientError, from client: CometdClientContract) {
    log.zp.debug("ClientHelper writeErrorReceived \(error.localizedDescription)")
  }
}
