//
//  CometdClient+Transport.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation

// MARK: Transport Delegate
extension CometdClient {
  public func didConnect() {
    self.connectionInitiated = false
    log.debug("CometdClient didConnect")
    self.handshake(self.handshakeFields!)
  }
  
  public func didDisconnect(_ error: Error?) {
    log.debug("CometdClient didDisconnect")
    self.delegate?.disconnectedFromServer(self)
    self.connectionInitiated = false
    self.cometdConnected = false
  }
  
  public func didFailConnection(_ error: Error?) {
    log.warning("CometdClient didFailConnection")
    self.delegate?.connectionFailed(self)
    self.connectionInitiated = false
    self.cometdConnected = false
  }
  
  public func didWriteError(_ error: Error?) {
    self.delegate?.cometdClientError(self, error: error ?? CometdSocketError.transportWrite)
  }
  
  public func didReceiveMessage(_ text: String) {
    self.receive(text)
  }
  
  public func didReceivePong() {
    self.delegate?.pongReceived(self)
  }
}
