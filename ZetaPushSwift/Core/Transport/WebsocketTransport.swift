//
//  WebsocketTransport.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation
import Starscream
import XCGLogger

// MARK: - WebsocketTransport
class WebsocketTransport: Transport {
  // MARK: Properties
  var urlString: String
  var webSocket: WebSocket?
  weak var delegate: TransportDelegate?
  
  let log = XCGLogger(identifier: "websocketLogger", includeDefaultDestinations: true)
  
  // MARK: Init
  init(url: String, logLevel: XCGLogger.Level = .severe) {
    self.urlString = url
    log.setup(level: logLevel)
  }
  
  func openConnection() {
    self.closeConnection()
    
    guard let url = URL(string: urlString) else {
      fatalError("WebSocket url isn't conform")
    }
    self.webSocket = WebSocket(url: url)
    if let webSocket = self.webSocket {
      webSocket.advancedDelegate = self
      webSocket.pongDelegate = self
      webSocket.connect()
      
      log.debug("Cometd: Opening connection with \(String(describing: self.urlString))")
    }
  }
  
  func closeConnection() {
    log.error("Cometd: close connection")
    if let webSocket = self.webSocket {
      webSocket.delegate = nil
      webSocket.disconnect(forceTimeout: 0)
      self.webSocket = nil
    }
  }
  
  func writeString(_ aString: String) {
    log.debug("Cometd: aString : \(aString)")
    self.webSocket?.write(string: aString)
  }
  
  func sendPing(_ data: Data, completion: (() -> Void)? = nil) {
    self.webSocket?.write(ping: data, completion: completion)
  }
  
  func isConnected() -> Bool {
    return self.webSocket?.isConnected ?? false
  }
}

// MARK: - WebsocketTransport + WebSocketPongDelegate
extension WebsocketTransport: WebSocketPongDelegate {
  func websocketDidReceivePong(_ socket: WebSocketClient) {
    self.delegate?.didReceivePong()
  }
  
  func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
    self.delegate?.didReceivePong()
  }
}

// MARK: - WebsocketTransport + WebSocketAdvancedDelegate
extension WebsocketTransport: WebSocketAdvancedDelegate {
  func websocketDidConnect(socket: WebSocket) {
    log.debug("Advanced transport delegate : connection did connect")
    self.delegate?.didConnect()
  }
  
  func websocketDidDisconnect(socket: WebSocket, error: Error?) {
    if error == nil {
      log.debug("Advanced transport delegate: lostConnection")
      self.delegate?.didDisconnect(CometdSocketError.lostConnection)
    } else {
      log.debug("Advanced transport delegate: error : \(String(describing: error))")
      self.delegate?.didFailConnection(error)
    }
  }
  
  func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
    log.debug("Advanced transport delegate: message: \(text), from response : \(response)")
    self.delegate?.didReceiveMessage(text)
  }
  
  func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
    log.debug("Advanced transport delegate: Received data: \(data.count), from response : \(response)")
  }
  
  func websocketHttpUpgrade(socket: WebSocket, request: String) {
    log.debug("Advanced transport delegate: uprage http with socket: \(socket) to request : \(request)")
  }
  
  func websocketHttpUpgrade(socket: WebSocket, response: String) {
    log.debug("Advanced transport delegate: uprage http with socket: \(socket) from response : \(response)")
  }
}
