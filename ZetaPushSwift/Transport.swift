//
//  Transport.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

// MARK: - Transport
public protocol Transport {
  func writeString(_ aString: String)
  func openConnection()
  func closeConnection()
  func isConnected() -> Bool
}

public protocol TransportDelegate: class {
  func didConnect()
  func didFailConnection(_ error: Error?)
  func didDisconnect(_ error: Error?)
  func didWriteError(_ error: Error?)
  func didReceiveMessage(_ text: String)
  func didReceivePong()
}
