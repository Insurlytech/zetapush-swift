//
//  CometdClient+Helper.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation

public extension CometdClient {
  // MARK: Helper
  ///  Validate whatever a subscription has been subscribed correctly
  func isSubscribedToChannel(_ channel: String) -> Bool {
    return self.openSubscriptions.contains { $0.subscriptionUrl == channel }
  }
  
  ///  Validate cometd transport is connected
  func isTransportConnected() -> Bool {
    return self.transport?.isConnected ?? false
  }
}

