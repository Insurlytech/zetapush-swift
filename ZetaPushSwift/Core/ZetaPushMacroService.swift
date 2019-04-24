//
//  ZetaPushMacroService.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

/*
 Macro Service
 
 Use his own subscription list to handle generic /completed channel when we call a macro with hardfail = true
 For the promise asyncCall function, the global (cometD) subscription list is used
 */
import Foundation
import PromiseKit
import XCGLogger
import Gloss

// MARK: - AbstractMacroCompletion
public protocol AbstractMacroCompletion {
  associatedtype resultType: Glossy
  
  var name: String { get set }
  var requestId: String { get set }
  var result: resultType { get set }
  
  init(result: resultType, name: String, requestId: String)
}

// MARK: - EmptyMessage
// Dummy class
public struct EmptyMessage: Glossy {
  // MARK: Properties
  let empty: String?
  
  // MARK: Lifecycle
  public init?(json: JSON) {
    self.empty = "empty" <~~ json
  }
  
  public func toJSON() -> JSON? {
    return jsonify([
      "empty" ~~> self.empty
      ])
  }
}

// MARK: - EmptyCompletion
// Class usefull for a macro with empty result
public struct EmptyCompletion: AbstractMacroCompletion {
  // MARK: Properties
  public typealias resultType = EmptyMessage
  
  public var result: EmptyMessage
  public var requestId: String
  public var name: String
  
  // MARK: Lifecycle
  public init(result: resultType, name: String, requestId: String) {
    self.result = result
    self.name = name
    self.requestId = requestId
  }
}

// MARK: - ZetaPushMacroError
public enum ZetaPushMacroError: Error {
  case genericError(macroName: String, errorMessage: String, errorCode: String, errorLocation: String)
  case unknowError
  case decodingError
  
  static func genericFromDictionnary(_ messageDict: NSDictionary) -> ZetaPushMacroError {
    guard let errorCode = messageDict["code"] as? String, let errorMessage = messageDict["message"] as? String else {
      return .unknowError
    }
    let errorLocation = messageDict["location"] as? String ?? ""
    var macroName = ""
    if let source = messageDict["source"] as? [String: Any] {
      let data = source["data"] as? [String: Any] ?? [:]
      macroName = data["name"] as? String ?? ""
    }
    return ZetaPushMacroError.genericError(macroName: macroName, errorMessage: errorMessage, errorCode: errorCode, errorLocation: errorLocation)
  }
}

// MARK: - ZetaPushMacroService
open class ZetaPushMacroService : NSObject {
  // MARK: Properties
  open var onMacroError: ZPMacroServiceErrorBlock?
  
  public let clientHelper: ClientHelper
  let deploymentId: String
  
  var channelSubscriptionBlocks = [String: [Subscription]]()
  
  let log = XCGLogger(identifier: "macroserviceLogger", includeDefaultDestinations: true)
  
  // Callback for /completed macro channel
  lazy var channelBlockMacroCompleted: ChannelSubscriptionBlock = { messageDict -> Void in
    self.log.debug("ZetaPushMacroService channelBlockMacroCompleted")
    self.log.debug(messageDict)
    
    guard let name = messageDict["name"] as? String else {
      return
    }
    let macroChannel = self.composeServiceChannel(name)
    guard let result = messageDict["result"] as? NSDictionary else {
      return
    }
    self.channelSubscriptionBlocks[macroChannel]?.forEach({ $0.callback?(result) })
  }
  
  // Callback for /error macro channel
  lazy var channelBlockMacroError:ChannelSubscriptionBlock = { messageDict -> Void in
    self.log.debug("ZetaPushMacroService channelBlockMacroError")
    self.log.debug(messageDict)
    
    self.onMacroError?(self, ZetaPushMacroError.genericFromDictionnary(messageDict))
  }
  
  // Callback for /trace macro channel
  lazy var channelBlockMacroTrace:ChannelSubscriptionBlock = { messageDict -> Void in
    self.log.debug("ZetaPushMacroService channelBlockMacroTrace")
    self.log.debug(messageDict)
    
    //self.onMacroError?(self, ZetaPushMacroError.genericFromDictionnary(messageDict))
  }
  
  // MARK: Lifecycle
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.deploymentId = deploymentId
    super.init()
    
    let macroChannel = composeServiceChannel("completed")
    let macroChannelError = composeServiceChannel("error")
    let macroChannelTrace = composeServiceChannel("trace")
    
    log.setup(level: clientHelper.getLogLevel())
    
    // Subscribe to completed macro channel
    self.clientHelper.subscribe(macroChannel, block: channelBlockMacroCompleted)
    self.clientHelper.subscribe(macroChannelError, block: channelBlockMacroError)
    self.clientHelper.subscribe(macroChannelTrace, block: channelBlockMacroTrace)
  }
  
  public convenience init(_ clientHelper: ClientHelper) {
    self.init(clientHelper, deploymentId: zetaPushDefaultConfig.macroDeployementId)
  }
  
  private func composeServiceChannel(_ verb: String) -> String {
    return "/service/" + clientHelper.getSandboxId() + "/" + deploymentId + "/" + verb
  }
  
  open func subscribe(verb: String, block: ChannelSubscriptionBlock? = nil) -> Subscription {
    let subscribedChannel = composeServiceChannel(verb)
    var sub = Subscription(callback: nil, channel: subscribedChannel, id: 0)
    if let block = block {
      if channelSubscriptionBlocks[subscribedChannel] == nil {
        channelSubscriptionBlocks[subscribedChannel] = []
      }
      // Create a structure to store the callback and the id of
      sub.callback = block
      sub.id = channelSubscriptionBlocks[subscribedChannel]?.count ?? 0
      channelSubscriptionBlocks[subscribedChannel]?.append(sub)
    }
    return sub
  }
  
  open func unsubscribe(_ subscription: Subscription) {
    var subscriptionArray = channelSubscriptionBlocks[subscription.channel]
    if let index = subscriptionArray?.firstIndex(of: subscription) {
      subscriptionArray?.remove(at: index)
    }
    if subscriptionArray?.isEmpty == true {
      self.channelSubscriptionBlocks[subscription.channel] = nil
    }
  }
  
  open func call(verb: String, parameters: NSDictionary) {
    let dict: [String: Any] = [
      "name": verb,
      "hardFail": true,
      "parameters": parameters
    ]
    clientHelper.publish(composeServiceChannel("call"), message: dict)
  }
  
  /*
   Call return a promise
   */
  open func call(verb: String, parameters: [String: Any]) -> Promise<NSDictionary> {
    return Promise { [weak self] seal in
      let requestId = UUID().uuidString
      let dict: [String: Any] = [
        "name": verb,
        "hardFail": false,
        "parameters": parameters,
        "requestId": requestId
      ]
      
      var sub: Subscription?
      let channelBlockMacroCall: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        // Check if the requestId is similar to the one sent
        if let msgRequestId = messageDict["requestId"] as? String, msgRequestId != requestId {
          return
        }
        
        guard let subscription = sub else {
          self?.log.zp.debug(#function + "subscription is nil")
          return
        }
        self?.clientHelper.unsubscribe(subscription)
        
        if let result = messageDict["result"] as? NSDictionary {
          seal.fulfill(result)
        }
        if let errors = messageDict["errors"] as? [[String: Any]], errors.isEmpty, let error = errors.first {
          seal.reject(ZetaPushMacroError.genericFromDictionnary(error as NSDictionary))
        } else {
          seal.reject(ZetaPushMacroError.unknowError)
        }
      }
      sub = self?.clientHelper.subscribe(composeServiceChannel(verb), block: channelBlockMacroCall)
      self?.clientHelper.publish(composeServiceChannel("call"), message: dict)
    }
  }
  
  open func call<T : Glossy, U: AbstractMacroCompletion>(verb: String, parameters: T) -> Promise<U> {
    return Promise { [weak self] seal in
      let requestId = UUID().uuidString
      let dict: [String: Any] = [
        "name": verb,
        "hardFail": false,
        "parameters": parameters.toJSON() ?? [:],
        "requestId": requestId
      ]
      
      var sub: Subscription?
      let channelBlockMacroCall: ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        // Check if the requestId is similar to the one sent
        if let msgRequestId = messageDict["requestId"] as? String, msgRequestId != requestId {
          return
        }
        
        guard let subscription = sub else {
          self?.log.zp.debug(#function + "subscription is nil")
          return
        }
        self?.clientHelper.unsubscribe(subscription)
        
        if let result = messageDict["result"] as? NSDictionary {
          guard let json = result as? JSON, let zpMessage = U.resultType(json: json) else {
            seal.reject(ZetaPushMacroError.decodingError)
            return
          }
          
          let completion = U(result: zpMessage, name: verb, requestId: requestId)
          seal.fulfill(completion)
        }
        if let errors = messageDict["errors"] as? [[String: Any]], errors.isEmpty, let error = errors.first {
          seal.reject(ZetaPushMacroError.genericFromDictionnary(error as NSDictionary))
        } else {
          seal.reject(ZetaPushMacroError.unknowError)
        }
      }
      
      sub = self?.clientHelper.subscribe(composeServiceChannel(verb), block: channelBlockMacroCall)
      self?.clientHelper.publish(composeServiceChannel("call"), message: dict)
    }
  }
  
  open func call<U: AbstractMacroCompletion>(verb: String) -> Promise<U> {
    return Promise { [weak self] seal in
      let requestId = UUID().uuidString
      let dict: [String: Any] = [
        "name": verb,
        "hardFail": false,
        "requestId": requestId
      ]
      var sub: Subscription?
      
      let channelBlockMacroCall:ChannelSubscriptionBlock = { [weak self] messageDict -> Void in
        // Check if the requestId is similar to the one sent
        if let msgRequestId = messageDict["requestId"] as? String, msgRequestId != requestId {
          return
        }
        
        guard let subscription = sub else {
          self?.log.zp.debug(#function + "subscription is nil")
          return
        }
        self?.clientHelper.unsubscribe(subscription)
        
        if let result = messageDict["result"] as? NSDictionary {
          guard let json = result as? JSON, let zpMessage = U.resultType(json: json) else {
            seal.reject(ZetaPushMacroError.decodingError)
            return
          }
          
          let completion = U(result: zpMessage, name: verb, requestId: requestId)
          seal.fulfill(completion)
        }
        if let errors = messageDict["errors"] as? [[String: Any]], errors.isEmpty, let error = errors.first {
          seal.reject(ZetaPushMacroError.genericFromDictionnary(error as NSDictionary))
        } else {
          seal.reject(ZetaPushMacroError.unknowError)
        }
      }
      
      sub = self?.clientHelper.subscribe(composeServiceChannel(verb), block: channelBlockMacroCall)
      self?.clientHelper.publish(composeServiceChannel("call"), message: dict)
    }
  }
  
  open func call<T: Glossy>(verb: String, parameters: T) {
    let dict: [String: Any] = [
      "name": verb,
      "hardFail": true,
      "parameters": parameters.toJSON() ?? [:]
    ]
    clientHelper.publish(composeServiceChannel("call"), message: dict)
  }
  
  open func call(verb: String) {
    let dict: [String: Any] = [
      "name": verb,
      "hardFail": true
    ]
    clientHelper.publish(composeServiceChannel("call"), message: dict)
  }
}
