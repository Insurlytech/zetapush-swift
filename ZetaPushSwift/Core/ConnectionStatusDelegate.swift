//
//  ZetaPushClientDelegate.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation

// MARK: - ConnectionStatusDelegate
public protocol ConnectionStatusDelegate: class {
  func onConnectionEstablished(_ client: ClientHelper)
  func onConnectionBroken(_ client: ClientHelper)
  func onConnectionClosed(_ client: ClientHelper)
  func onSuccessfulHandshake(_ client: ClientHelper)
  func onFailedHandshake(_ client: ClientHelper)
}

public extension ConnectionStatusDelegate {
  func onConnectionEstablished(_ client: ClientHelper) { }
  func onConnectionBroken(_ client: ClientHelper) { }
  func onConnectionClosed(_ client: ClientHelper) { }
  func onSuccessfulHandshake(_ client: ClientHelper) { }
  func onFailedHandshake(_ client: ClientHelper) { }
}
