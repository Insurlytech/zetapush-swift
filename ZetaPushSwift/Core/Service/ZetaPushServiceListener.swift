//
//  ZetaPushServiceListener.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import Gloss

// MARK: - ModelBlockTuple
public struct ModelBlockTuple {
  let model: CometdSubscriptionModel
  let block: ChannelSubscriptionBlock?
}

// MARK: - ZetaPushServiceListener
open class ZetaPushServiceListener {
  // MARK: Properties
  public let clientHelper: ClientHelper
  var macroChannelError: String
  public var zetaPushService: ZetaPushService
  open var onServiceError: ZPServiceErrorBlock?
  
  // Callback for /error macro channel
  lazy var channelBlockMacroError:ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
    guard let self = self else { return }
    self.onServiceError?(self.zetaPushService, ZetaPushServiceError.genericFromDictionnary(messageDict))
  }
  
  /// Must be overriden by descendants
  open func register() { }
  
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.zetaPushService = ZetaPushService(clientHelper, deploymentId: deploymentId)
    
    self.macroChannelError = "/service/" + self.clientHelper.getSandboxId() + "/" + deploymentId + "/" + "error"
    self.clientHelper.subscribe(macroChannelError, block: channelBlockMacroError)
    
    // TODO: refact register https://github.com/Insurlytech/zetapush-swift/issues/16
//    self.register()
  }
  
  ///
  public func getModelBlock<T: Glossy>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: clientHelper.cometdClient.cometdClientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  ///
  public func getModelBlock<T: Glossy>(verb: String, callback: @escaping ([T]) -> Void) -> ModelBlockTuple {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: clientHelper.cometdClient.cometdClientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      guard let zpMessage: [T] = self.parse(messageDict: messageDict) else {
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  ///
  public func getModelBlock<T: NSDictionary>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: self.clientHelper.cometdClient.cometdClientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  ///
  public func subscribe(_ tuples: [ModelBlockTuple]) {
    clientHelper.subscribe(tuples)
  }
  
  /// Generic Subscribe with a Generic parameter
  public func subscribe<T: Glossy>(verb: String, callback: @escaping (T) -> Void) {
    let channelBlockServiceCall: ChannelSubscriptionBlock =  { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
        return
      }
      callback(zpMessage)
    }
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushService.deploymentId)
    clientHelper.subscribe(channel, block: channelBlockServiceCall)
  }
  
  /// Generic Subscribe with a Generic Array parameter
  public func subscribe<T: Glossy>(verb: String, callback: @escaping ([T]) -> Void) {
    let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      guard let zpMessage: [T] = self.parse(messageDict: messageDict) else {
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
        return
      }
      callback(zpMessage)
    }
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushService.deploymentId)
    clientHelper.subscribe(channel, block: channelBlockServiceCall)
  }
  
  /// Generic Subscribe with a NSDictionary parameter
  public func subscribe<T: NSDictionary>(verb: String, callback: @escaping (T) -> Void) {
    let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
        return
      }
      callback(zpMessage)
    }
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushService.deploymentId)
    clientHelper.subscribe(channel, block: channelBlockServiceCall)
  }
  
  // MARK: - private funcs
  private func parse<T: Glossy>(messageDict: NSDictionary) -> T? {
    return T(json: messageDict as? JSON ?? [:])
  }
  
  private func parse<T: Glossy>(messageDict: NSDictionary) -> [T]? {
    return [T].from(jsonArray: messageDict.allKeys.compactMap({ $0 as? JSON }))
  }
  
  private func parse<T: NSDictionary>(messageDict: NSDictionary) -> T? {
    return messageDict as? T
  }
}
