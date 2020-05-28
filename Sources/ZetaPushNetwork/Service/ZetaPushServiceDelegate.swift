//
//  ZetaPushServiceDelegate.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import CometDClient
import Foundation

// MARK: - ZetaPushServiceDelegate
public protocol ZetaPushServiceDelegate: NSObjectProtocol {
  func onDidSubscribeToChannel(_ client: ClientHelper, channel: String)
  func onDidUnsubscribeFromChannel(_ client: ClientHelper, channel: String)
  func onSubscriptionFailedWithError(_ client: ClientHelper, error: SubscriptionError)
}

public extension ZetaPushServiceDelegate {
  func onDidSubscribeToChannel(_ client: ClientHelper, channel: String) { }
  func onDidUnsubscribeFromChannel(_ client: ClientHelper, channel: String) { }
  func onSubscriptionFailedWithError(_ client: ClientHelper, error: SubscriptionError) { }
}
