//
//  CometdClient+Action.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation

extension CometdClient {
  // MARK: Private - Timer Action
  @objc
  func pendingSubscriptionsAction(_ timer: Timer) {
    guard cometdConnected == true else {
      log.error("Cometd: Failed to resubscribe to all pending channels, socket disconnected")
      return
    }
    resubscribeToPendingSubscriptions()
  }
}
