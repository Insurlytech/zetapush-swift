//
//  ZetaPushService.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import PromiseKit
import XCGLogger
import Gloss

// MARK: - ZetaPushServiceError
public enum ZetaPushServiceError: Error {
  case genericError(errorCode: String, errorMessage: String, errorSource: NSDictionary)
  case unknowError
  case decodingError
  
  static func genericFromDictionnary(_ messageDict: NSDictionary) -> ZetaPushServiceError {
    let errorCode = messageDict["code"] as? String ?? ""
    let errorMessage = messageDict["message"] as? String ?? ""
    let errorSource = messageDict["source"] as? NSDictionary ?? [:]
    
    return ZetaPushServiceError.genericError(errorCode: errorCode, errorMessage: errorMessage, errorSource: errorSource)
  }
}

// MARK: - ZetaPushService
open class ZetaPushService: NSObject {
  // MARK: Properties
  public var clientHelper: ClientHelper?
  var deploymentId: String?
  
  let log = XCGLogger(identifier: "serviceLogger", includeDefaultDestinations: true)
  
  // MARK: Lifecycle
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.deploymentId = deploymentId
    
    super.init()
    
    if let level = self.clientHelper?.getLogLevel() {
      self.log.setup(level: level)
    }
  }
  
  // MARK: Methods
  open func subscribe(verb: String, block: ChannelSubscriptionBlock? = nil) -> Subscription? {
    guard let deploymentId = self.deploymentId, let subscribedChannel = self.clientHelper?.composeServiceChannel(verb, deploymentId: deploymentId) else {
        self.log.error("self.clientHelper?.composeServiceChannel error")
        return nil
    }
    guard let sub = self.clientHelper?.subscribe(subscribedChannel, block: block) else {
        self.log.error("self.clientHelper!.subscribe error")
        return nil
    }
    return sub
  }
  
  open func unsubscribe(_ subscription:Subscription) {
    self.clientHelper?.unsubscribe(subscription)
  }
  
  open func publish(verb: String, parameters: NSDictionary) {
    guard let deploymentId = self.deploymentId,
      let channel = self.clientHelper?.composeServiceChannel(verb, deploymentId: deploymentId),
      let message = parameters as? [String: Any] else {
      return
    }
    clientHelper?.publish(channel, message: message)
  }
  
  open func publish(verb: String, parameters: [String: Any]) -> Promise<NSDictionary> {
    return Promise { [weak self] seal in
      var sub: Subscription?
      var subError: Subscription?
      
      let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let _sub = sub, let _subError = subError else { return }
        self?.clientHelper?.unsubscribe(_sub)
        self?.clientHelper?.unsubscribe(_subError)
        seal.fulfill(messageDict)
      }
      
      let channelBlockServiceError:ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let _sub = sub, let _subError = subError else { return }
        self?.clientHelper?.unsubscribe(_sub)
        self?.clientHelper?.unsubscribe(_subError)
        seal.reject(ZetaPushServiceError.genericFromDictionnary(messageDict))
      }
      
      guard let clientHelper = self?.clientHelper, let deploymentId = self?.deploymentId else {
        return
      }
      sub = clientHelper.subscribe(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), block: channelBlockServiceCall)
      subError = clientHelper.subscribe(clientHelper.composeServiceChannel("error", deploymentId: deploymentId), block: channelBlockServiceError)
      
      clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: parameters)
    }
  }
  
  open func publish<T: Glossy, U: Glossy>(verb: String, parameters: T) -> Promise<U> {
    return Promise { [weak self]  seal in
      var sub: Subscription? = nil
      var subError: Subscription? = nil
      
      let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let _sub = sub, let _subError = subError else { return }
        self?.clientHelper?.unsubscribe(_sub)
        self?.clientHelper?.unsubscribe(_subError)
        
        guard let zpMessage = U(json: messageDict as! JSON) else {
          seal.reject(ZetaPushServiceError.decodingError)
          return
        }
        seal.fulfill(zpMessage)
      }
      
      let channelBlockServiceError: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let _sub = sub, let _subError = subError else { return }
        self?.clientHelper?.unsubscribe(_sub)
        self?.clientHelper?.unsubscribe(_subError)
        
        seal.reject(ZetaPushServiceError.genericFromDictionnary(messageDict))
      }
      
      guard let clientHelper = self?.clientHelper, let deploymentId = self?.deploymentId else {
        return
      }
      sub = clientHelper.subscribe(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), block: channelBlockServiceCall)
      subError = clientHelper.subscribe(clientHelper.composeServiceChannel("error", deploymentId: deploymentId), block: channelBlockServiceError)
      let message = parameters.toJSON() as? [String: Any] ?? [:]
      clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: message)
    }
  }
  
  open func publish<T: Glossy>(verb: String, parameters: T) {
    guard let clientHelper = self.clientHelper, let deploymentId = self.deploymentId else {
      return
    }
    let message = parameters.toJSON() as? [String: Any] ?? [:]
    clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: message)
  }
  
  open func publish(verb: String) {
    guard let clientHelper = self.clientHelper, let deploymentId = self.deploymentId else {
      return
    }
    clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: ["":""])
  }
}


