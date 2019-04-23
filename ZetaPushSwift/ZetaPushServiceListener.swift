//
//  ZetaPushServiceListener.swift
//  ZetaPushSwift
//
//  Created by Mikael Morvan on 24/04/2017.
//  Copyright © 2017 ZetaPush. All rights reserved.
//

import Foundation
import Gloss

public struct ModelBlockTuple {
    let model: CometdSubscriptionModel
    let block: ChannelSubscriptionBlock?
}

open class ZetaPushServiceListener{
    public let clientHelper: ClientHelper
    var macroChannelError: String
    public var zetaPushService: ZetaPushService
    open var onServiceError: ZPServiceErrorBlock?
    
    // Callback for /error macro channel
    lazy var channelBlockMacroError:ChannelSubscriptionBlock = { (messageDict) -> Void in
        self.onServiceError?(self.zetaPushService, ZetaPushServiceError.genericFromDictionnary(messageDict))
    }
    
    // Must be overriden by descendants
    open func register() {}
    
    public init(_ clientHelper: ClientHelper, deploymentId: String) {
        self.clientHelper = clientHelper
        self.zetaPushService = ZetaPushService(clientHelper, deploymentId: deploymentId)
        
        self.macroChannelError = "/service/" + self.clientHelper.getSandboxId() + "/" + deploymentId + "/" + "error"
        self.clientHelper.subscribe(self.macroChannelError, block: channelBlockMacroError)
        
        self.register()
    }
    
    ///
    public func getModelBlock<T: Glossy>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
        let channel: String = self.clientHelper.composeServiceChannel(verb, deploymentId: self.zetaPushService.deploymentId)
        let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: self.clientHelper.cometdClient.cometdClientId)
        return ModelBlockTuple(model: model, block: {(messageDict: NSDictionary) -> Void in
            guard let zpMessage: T = self.parse(messageDict: messageDict) else {
                self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
                return
            }
            callback(zpMessage)
        })
    }
    
    ///
    public func getModelBlock<T: Glossy>(verb: String, callback: @escaping ([T]) -> Void) -> ModelBlockTuple {
        let channel: String = self.clientHelper.composeServiceChannel(verb, deploymentId: self.zetaPushService.deploymentId)
        let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: self.clientHelper.cometdClient.cometdClientId)
        return ModelBlockTuple(model: model, block: { (messageDict: NSDictionary) -> Void in
            guard let zpMessage: [T] = self.parse(messageDict: messageDict) else {
                self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
                return
            }
            callback(zpMessage)
        })
    }
    
    ///
    public func getModelBlock<T: NSDictionary>(verb: String, callback: @escaping (T) -> Void) -> ModelBlockTuple {
        let channel: String = self.clientHelper.composeServiceChannel(verb, deploymentId: self.zetaPushService.deploymentId)
        let model = CometdSubscriptionModel(subscriptionUrl: channel, clientId: self.clientHelper.cometdClient.cometdClientId)
        return ModelBlockTuple(model: model, block: { (messageDict: NSDictionary) -> Void in
            guard let zpMessage: T = self.parse(messageDict: messageDict) else {
                self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
                return
            }
            callback(zpMessage)
        })
    }
    
    ///
    public func subscribe(_ tuples: [ModelBlockTuple]) {
        self.clientHelper.subscribe(tuples)
    }

    /// Generic Subscribe with a Generic parameter
    public func subscribe<T: Glossy>(verb: String, callback: @escaping (T) -> Void) {
        
        let channelBlockServiceCall: ChannelSubscriptionBlock =  {(messageDict) -> Void in
            
            guard let zpMessage: T = self.parse(messageDict: messageDict) else {
                self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
                return
            }
            callback(zpMessage)
        }
        let channel: String = self.clientHelper.composeServiceChannel(verb, deploymentId: self.zetaPushService.deploymentId)
        self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
    }

    /// Generic Subscribe with a Generic Array parameter
    public func subscribe<T: Glossy>(verb: String, callback: @escaping ([T]) -> Void) {
        
        let channelBlockServiceCall: ChannelSubscriptionBlock = { (messageDict) -> Void in
            
            guard let zpMessage: [T] = self.parse(messageDict: messageDict) else {
                self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
                return
            }
            callback(zpMessage)
        }
        let channel: String = self.clientHelper.composeServiceChannel(verb, deploymentId: self.zetaPushService.deploymentId)
        self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
    }

    /// Generic Subscribe with a NSDictionary parameter
    public func subscribe<T: NSDictionary>(verb: String, callback: @escaping (T) -> Void) {
        let channelBlockServiceCall: ChannelSubscriptionBlock = { (messageDict) -> Void in
            guard let zpMessage: T = self.parse(messageDict: messageDict) else {
                self.onServiceError?(self.zetaPushService, ZetaPushServiceError.decodingError)
                return
            }
            callback(zpMessage)
        }
        let channel: String = self.clientHelper.composeServiceChannel(verb, deploymentId: self.zetaPushService.deploymentId)
        self.clientHelper.subscribe(channel, block: channelBlockServiceCall)
    }
    
    // MARK: - private funcs
    private func parse<T: Glossy>(messageDict: NSDictionary) -> T? {
        return T(json: messageDict as! JSON)
    }
    
    private func parse<T: Glossy>(messageDict: NSDictionary) -> [T]? {
        return [T].from(jsonArray: messageDict.allKeys as! [JSON])
    }
    
    private func parse<T: NSDictionary>(messageDict: NSDictionary) -> T? {
        return messageDict as? T
    }
}
