//
//  WebsocketTransport.swift
//  ZetaPushSwift
//
//  Created by Morvan Mikaël on 23/03/2017.
//  Copyright © 2017 ZetaPush. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation
import Starscream
import XCGLogger

internal class WebsocketTransport: Transport {
  
  var urlString: String?
  var webSocket: WebSocket?
  internal weak var delegate: TransportDelegate?
  
  let log = XCGLogger(identifier: "websocketLogger", includeDefaultDestinations: true)
  
  convenience required internal init(url: String, logLevel: XCGLogger.Level = .severe) {
    self.init()
    self.urlString = url
    log.setup(level: logLevel)
  }
  
  func openConnection() {
    self.closeConnection()
    self.webSocket = WebSocket(url: URL(string:self.urlString!)!)
    if let webSocket = self.webSocket {
//      webSocket.delegate = self
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
  
  func writeString(_ aString:String) {
    log.debug("Cometd: aString : \(aString)")
    self.webSocket?.write(string: aString)
  }
  
  func sendPing(_ data: Data, completion: (() -> ())? = nil) {
    self.webSocket?.write(ping: data, completion: completion)
  }
  
  func isConnected() -> (Bool) {
    return self.webSocket?.isConnected ?? false
  }
}

extension WebsocketTransport: WebSocketPongDelegate {
  // MARK: WebSocket Pong Delegate
  internal func websocketDidReceivePong(_ socket: WebSocketClient) {
    self.delegate?.didReceivePong()
  }
  
  func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
    self.delegate?.didReceivePong()
  }
}

//extension WebsocketTransport: WebSocketDelegate {
//  internal func websocketDidConnect(socket: WebSocketClient) {
//    log.debug()
//    self.delegate?.didConnect()
//  }
//
//  internal func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//    if error == nil {
//      log.debug("Cometd: lostConnection")
//      self.delegate?.didDisconnect(CometdSocketError.lostConnection)
//    } else {
//      log.debug("Cometd: error : \(error)")
//      self.delegate?.didFailConnection(error)
//    }
//  }
//
//  internal func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//    log.debug("Cometd: message: \(text)")
//    self.delegate?.didReceiveMessage(text)
//  }
//
//  // MARK: TODO
//  internal func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//    log.debug("Cometd: Received data: \(data.count)")
//    //self.socket.writeData(data)
//  }
//
//}

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
    //self.socket.writeData(data)
  }
  
  func websocketHttpUpgrade(socket: WebSocket, request: String) {
    log.debug("Advanced transport delegate: uprage http with socket: \(socket) to request : \(request)")
  }
  
  func websocketHttpUpgrade(socket: WebSocket, response: String) {
    log.debug("Advanced transport delegate: uprage http with socket: \(socket) from response : \(response)")
  }
}

