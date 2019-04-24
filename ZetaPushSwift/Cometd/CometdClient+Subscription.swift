//
//  CometdClient+Subscription.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation
import SwiftyJSON

// MARK: Private Internal methods
extension CometdClient {
  func subscribeQueuedSubscriptions() {
    // if there are any outstanding open subscriptions resubscribe
    self.queuedSubscriptions.forEach { removeChannelFromQueuedSubscriptions($0.subscriptionUrl) }
    self.subscribe(self.queuedSubscriptions)
  }
  
  func resubscribeToPendingSubscriptions() {
    if !pendingSubscriptions.isEmpty {
      log.debug("Cometd: Resubscribing to \(pendingSubscriptions.count) pending subscriptions")
      self.pendingSubscriptions.forEach { removeChannelFromPendingSubscriptions($0.subscriptionUrl) }
      self.subscribe(self.pendingSubscriptions)
    }
  }
  
  func unsubscribeAllSubscriptions() {
    let subscriptionsModels = queuedSubscriptions + openSubscriptions + pendingSubscriptions
    let subscriptions = subscriptionsModels.compactMap({ Subscription(callback: nil, channel: $0.subscriptionUrl, id: $0.id) })
    subscriptions.forEach({ clearSubscriptionFromChannel($0) })
  }
  
  // MARK: Send/Receive
  func send(_ message: NSDictionary) {
    writeOperationQueue.async { [unowned self] in
      if let string = JSON(message).rawString() {
        self.transport?.writeString(string)
      }
    }
  }
  
  func receive(_ message: String) {
    readOperationQueue.sync { [unowned self] in
      if let jsonData = message.data(using: String.Encoding.utf8, allowLossyConversion: false) {
        if let json = try? JSON(data: jsonData) {
          self.parseCometdMessage(json.arrayValue)
        }
      }
    }
  }
  
  func nextMessageId() -> String {
    self.messageNumber += 1
    
    if self.messageNumber >= UInt32.max {
      messageNumber = 0
    }
    
    return "\(self.messageNumber)".zp.encodedString()
  }
  
  // MARK: Subscriptions
  
  @discardableResult
  func removeChannelFromQueuedSubscriptions(_ channel: String) -> Bool {
    objc_sync_enter(self.queuedSubscriptions)
    defer { objc_sync_exit(self.queuedSubscriptions) }
    
    let index = self.queuedSubscriptions.firstIndex { $0.subscriptionUrl == channel }
    
    if let index = index {
      self.queuedSubscriptions.remove(at: index)
      return true
    }
    return false
  }
  
  @discardableResult
  func removeChannelFromPendingSubscriptions(_ channel: String) -> Bool {
    objc_sync_enter(self.pendingSubscriptions)
    defer { objc_sync_exit(self.pendingSubscriptions) }
    
    let index = self.pendingSubscriptions.firstIndex { $0.subscriptionUrl == channel }
    
    if let index = index {
      self.pendingSubscriptions.remove(at: index)
      return true
    }
    return false
  }
  
  @discardableResult
  func removeChannelFromOpenSubscriptions(_ channel: String) -> Bool {
    objc_sync_enter(self.pendingSubscriptions)
    defer { objc_sync_exit(self.pendingSubscriptions) }
    
    let index = self.openSubscriptions.firstIndex { $0.subscriptionUrl == channel }
    
    if let index = index {
      self.openSubscriptions.remove(at: index)
      return true
    }
    return false
  }
}

