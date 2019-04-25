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
    guard let errorCode = messageDict["code"] as? String, let errorMessage = messageDict["message"] as? String else {
      return .unknowError
    }
    let errorSource = messageDict["source"] as? NSDictionary ?? [:]
    return ZetaPushServiceError.genericError(errorCode: errorCode, errorMessage: errorMessage, errorSource: errorSource)
  }
}

// MARK: - ZetaPushService
open class ZetaPushService: NSObject {
  // MARK: Properties
  public let clientHelper: ClientHelper
  let deploymentId: String
  
  let log = XCGLogger(identifier: "serviceLogger", includeDefaultDestinations: true)
  
  // MARK: Lifecycle
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.deploymentId = deploymentId
    super.init()
    
    log.setup(level: clientHelper.getLogLevel())
  }
  
  // MARK: Methods
  open func subscribe(verb: String, block: ChannelSubscriptionBlock? = nil) -> Subscription? {
    let subscribedChannel = clientHelper.composeServiceChannel(verb, deploymentId: deploymentId)
    guard let sub = clientHelper.subscribe(subscribedChannel, block: block) else {
        self.log.error("self.clientHelper!.subscribe error")
        return nil
    }
    return sub
  }
  
  open func unsubscribe(_ subscription:Subscription) {
    clientHelper.unsubscribe(subscription)
  }
  
  open func publish(verb: String, parameters: NSDictionary) {
    let channel = clientHelper.composeServiceChannel(verb, deploymentId: deploymentId)
    guard let message = parameters as? [String: Any] else {
        log.zp.error(#function + "deploymentId or channel or message is nil")
      return
    }
    clientHelper.publish(channel, message: message)
  }
  
  open func publish(verb: String, parameters: [String: Any]) -> Promise<NSDictionary> {
    return Promise { [weak self] seal in
      var sub: Subscription?
      var subError: Subscription?
      
      let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let sub = sub, let subError = subError else {
          self?.log.zp.error(#function + "sub or subError is nil")
          return
        }
        self?.clientHelper.unsubscribe(sub)
        self?.clientHelper.unsubscribe(subError)
        seal.fulfill(messageDict)
      }
      
      let channelBlockServiceError: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let sub = sub, let subError = subError else {
          self?.log.zp.error(#function + "sub or subError is nil")
          return
        }
        self?.clientHelper.unsubscribe(sub)
        self?.clientHelper.unsubscribe(subError)
        seal.reject(ZetaPushServiceError.genericFromDictionnary(messageDict))
      }
      
      sub = clientHelper.subscribe(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), block: channelBlockServiceCall)
      subError = clientHelper.subscribe(clientHelper.composeServiceChannel("error", deploymentId: deploymentId), block: channelBlockServiceError)
      
      clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: parameters)
    }
  }
  
  open func publish<T: Glossy, U: Glossy>(verb: String, parameters: T) -> Promise<U> {
    return Promise { [weak self]  seal in
      var sub: Subscription?
      var subError: Subscription?
      
      let channelBlockServiceCall: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let sub = sub, let subError = subError else {
          self?.log.zp.error(#function + "sub or subError is nil")
          return
        }
        self?.clientHelper.unsubscribe(sub)
        self?.clientHelper.unsubscribe(subError)
        
        guard let json = messageDict as? JSON, let zpMessage = U(json: json) else {
          seal.reject(ZetaPushServiceError.decodingError)
          return
        }
        seal.fulfill(zpMessage)
      }
      
      let channelBlockServiceError: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        guard let sub = sub, let subError = subError else {
          self?.log.zp.error(#function + "sub or subError is nil")
          return
        }
        self?.clientHelper.unsubscribe(sub)
        self?.clientHelper.unsubscribe(subError)
        
        seal.reject(ZetaPushServiceError.genericFromDictionnary(messageDict))
      }
      
      sub = clientHelper.subscribe(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), block: channelBlockServiceCall)
      subError = clientHelper.subscribe(clientHelper.composeServiceChannel("error", deploymentId: deploymentId), block: channelBlockServiceError)
      guard let message = parameters.toJSON() else {
        log.zp.error(#function + "message is nil")
        return
      }
      clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: message)
    }
  }
  
  open func publish<T: Glossy>(verb: String, parameters: T) {
    guard let message = parameters.toJSON() else {
      log.zp.error(#function + "message is nil")
      return
    }
    clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: message)
  }
  
  open func publish(verb: String) {
    clientHelper.publish(clientHelper.composeServiceChannel(verb, deploymentId: deploymentId), message: ["":""])
  }
}
