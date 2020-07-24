//
//  ZetaPushMacroListener.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import CometDClient
import Foundation
import Gloss

// MARK: - ZetaPushMacroListener
open class ZetaPushMacroListener {
  // MARK: Properties
  public let clientHelper: ClientHelper
  public var zetaPushMacroService: ZetaPushMacroService
  open var onMacroError: ZPMacroServiceErrorBlock?
  
  // MARK: Lifecycle
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.zetaPushMacroService = ZetaPushMacroService(clientHelper, deploymentId: deploymentId)
    
    // TODO: refact register https://github.com/Insurlytech/zetapush-swift/issues/16
//    self.register()
  }
  
  /// Must be overriden by descendants
  open func register() { }
  
  public convenience init(_ clientHelper: ClientHelper) {
    self.init(clientHelper, deploymentId: ZetaPushDefaultConfig.macroDeployementId)
  }
  /**
   
   */
  public func getModelBlock<T: Glossy>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
    let channel = self.clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: clientHelper.cometdClient.clientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  public func getModelBlock<T: Glossy>(verb: String, callback: @escaping ([T]) -> Void) -> ModelBlockTuple {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: clientHelper.cometdClient.clientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: [T] = self.parse(messageDict: messageDict) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  public func getModelBlock<T: AbstractMacroCompletion>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: clientHelper.cometdClient.clientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: T = self.parse(messageDict: messageDict, verb: verb) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  public func getModelBlock<T: NSDictionary>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: clientHelper.cometdClient.clientId)
    return ModelBlockTuple(model: model, block: { [weak self] (messageDict: NSDictionary) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    })
  }
  
  public func subscribe(_ tuples: [ModelBlockTuple]) {
    clientHelper.subscribe(tuples)
  }
  
  /// Generic Subscribe with a Generic parameter
  public func subscribe<T: Glossy>(verb: String, callback: @escaping (T) -> Void) {
    let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    }
    let channel = self.clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
  }
  
  /// Generic Subscribe with a Generic parameter
  public func subscribe<T: AbstractMacroCompletion>(verb: String, callback: @escaping (T) -> Void) {
    let channelBlockServiceCall:ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: T = self.parse(messageDict: messageDict, verb: verb) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    }
    let channel = self.clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
  }
  
  /// Generic Subscribe with a Generic Array parameter
  public func subscribe<T: Glossy>(verb: String, callback: @escaping ([T]) -> Void) {
    let channelBlockServiceCall:ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: [T] = self.parse(messageDict: messageDict) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    }
    
    let channel = self.clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
    
  }
  
  /// Generic Subscribe with a NSDictionary parameter
  public func subscribe<T: NSDictionary>(verb: String, callback: @escaping (T) -> Void) {
    let channelBlockServiceCall:ChannelSubscriptionBlock = { [weak self] (messageDict) -> Void in
      guard let self = self else { return }
      self.handleMacroErrors(from: messageDict)
      guard let zpMessage: T = self.parse(messageDict: messageDict) else {
        self.onMacroError?(self.zetaPushMacroService, ZetaPushMacroError.decodingError)
        return
      }
      callback(zpMessage)
    }
    
    let channel = self.clientHelper.composeServiceChannel(verb, deploymentId: zetaPushMacroService.deploymentId)
    self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
  }
  
  // MARK: - private funcs
  private func handleMacroErrors(from messageDict: NSDictionary) {
    guard let errors = messageDict["errors"] as? [Any], !errors.isEmpty else {
      return
    }
    if let error = errors.first as? NSDictionary {
      onMacroError?(zetaPushMacroService, ZetaPushMacroError.genericFromDictionnary(error))
    } else {
      onMacroError?(zetaPushMacroService, ZetaPushMacroError.unknowError)
    }
  }
  
  private func parse<T: Glossy>(messageDict: NSDictionary) -> T? {
    guard let result = messageDict["result"] as? NSDictionary,
      let json = result as? JSON,
      let zpMessage = T(json: json) else {
        return nil
    }
    return zpMessage
  }
  
  private func parse<T: Glossy>(messageDict: NSDictionary) -> [T]? {
    guard let result = messageDict["result"] as? NSDictionary,
      let zpMessage = [T].from(jsonArray: result.allKeys.compactMap({ $0 as? JSON })) else {
        return nil
    }
    return zpMessage
  }
  
  private func parse<T: AbstractMacroCompletion>(messageDict: NSDictionary, verb: String) -> T? {
    guard let result = messageDict["result"] as? NSDictionary,
      let json = result as? JSON,
      let zpMessage = T.resultType(json: json) else {
        return nil
    }
    return T(result: zpMessage, name: verb, requestId: "")
  }
  
  private func parse<T: NSDictionary>(messageDict: NSDictionary) -> T? {
    guard let zpMessage = messageDict["result"] as? T else {
      return nil
    }
    return zpMessage
  }
}
