//
//  ClientHelperDelegate.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation

// MARK: CometdClientDelegate
public protocol ClientHelperDelegate: class {
  func onConnectionEstablished(_ client: ClientHelper)
  func onConnectionBroken(_ client: ClientHelper)
  func onConnectionClosed(_ client: ClientHelper)
  func onConnectionClosedAdviceReconnect(_ client: ClientHelper)
  func onSuccessfulHandshake(_ client: ClientHelper)
  func onFailedHandshake(_ client: ClientHelper)
  func onDidSubscribeToChannel(_ client: ClientHelper, channel: String)
  func onDidUnsubscribeFromChannel(_ client: ClientHelper, channel: String)
  func onSubscriptionFailedWithError(_ client: ClientHelper, error: subscriptionError)
}

public extension ClientHelperDelegate {
  func onConnectionEstablished(_ client: ClientHelper) { }
  func onConnectionBroken(_ client: ClientHelper) { }
  func onConnectionClosed(_ client: ClientHelper) { }
  func onConnectionClosedAdviceReconnect(_ client: ClientHelper) { }
  func onSuccessfulHandshake(_ client: ClientHelper) { }
  func onFailedHandshake(_ client: ClientHelper) { }
  func onDidSubscribeToChannel(_ client: ClientHelper, channel: String) { }
  func onDidUnsubscribeFromChannel(_ client: ClientHelper, channel: String) { }
  func onSubscriptionFailedWithError(_ client: ClientHelper, error: subscriptionError) { }
}
