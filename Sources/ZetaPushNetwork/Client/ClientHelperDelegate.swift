//
//  ClientHelperDelegate.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import CometDClient
import Foundation

// MARK: CometdClientDelegate
public protocol ClientHelperDelegate: class {
  func onConnectionFailed(_ client: ClientHelper, error: ClientHelperError)
  func onConnectionEstablished(_ client: ClientHelper)
  func onConnectionBroken(_ client: ClientHelper, error: ClientHelperError)
  func onConnectionClosed(_ client: ClientHelper, error: ClientHelperError?)
  func onConnectionClosedAdviceReconnect(_ client: ClientHelper)
  func onSuccessfulHandshake(_ client: ClientHelper)
  func onFailedHandshake(_ client: ClientHelper, error: ClientHelperError)
  func onDidSubscribeToChannel(_ client: ClientHelper, channel: String)
  func onDidUnsubscribeFromChannel(_ client: ClientHelper, channel: String)
  func onSubscriptionFailedWithError(_ client: ClientHelper, error: ClientHelperError)
}

public extension ClientHelperDelegate {
  func onConnectionFailed(_ client: ClientHelper, error: ClientHelperError) { }
  func onConnectionEstablished(_ client: ClientHelper) { }
  func onConnectionBroken(_ client: ClientHelper, error: ClientHelperError) { }
  func onConnectionClosed(_ client: ClientHelper, error: ClientHelperError?) { }
  func onConnectionClosedAdviceReconnect(_ client: ClientHelper) { }
  func onSuccessfulHandshake(_ client: ClientHelper) { }
  func onFailedHandshake(_ client: ClientHelper, error: ClientHelperError) { }
  func onDidSubscribeToChannel(_ client: ClientHelper, channel: String) { }
  func onDidUnsubscribeFromChannel(_ client: ClientHelper, channel: String) { }
  func onSubscriptionFailedWithError(_ client: ClientHelper, error: ClientHelperError) { }
}
