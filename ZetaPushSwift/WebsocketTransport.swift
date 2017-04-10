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

internal class WebsocketTransport: Transport, WebSocketDelegate, WebSocketPongDelegate {
    var urlString:String?
    var webSocket:WebSocket?
    internal weak var delegate:TransportDelegate?
    
    convenience required internal init(url: String) {
        self.init()
        print ("WebsocketTransport init", url)
        self.urlString = url
    }
    
    func openConnection() {
        self.closeConnection()
        self.webSocket = WebSocket(url: URL(string:self.urlString!)!)
        print ("WebsocketTransport openConnection", self.urlString!)
        if let webSocket = self.webSocket {
            webSocket.delegate = self
            webSocket.pongDelegate = self
            webSocket.connect()
            
            print("Cometd: Opening connection with \(String(describing: self.urlString))")
        }
    }
    
    func closeConnection() {
        if let webSocket = self.webSocket {
            print("Cometd: Closing connection")
            
            webSocket.delegate = nil
            webSocket.disconnect(forceTimeout: 0)
            
            self.webSocket = nil
        }
    }
    
    func writeString(_ aString:String) {
        self.webSocket?.write(string: aString)
    }
    
    func sendPing(_ data: Data, completion: (() -> ())? = nil) {
        self.webSocket?.write(ping: data, completion: completion)
    }
    
    func isConnected() -> (Bool) {
        return self.webSocket?.isConnected ?? false
    }
    
    // MARK: Websocket Delegate
    internal func websocketDidConnect(socket: WebSocket) {
        print("WebsocketTransport websocketDidConnect")
        self.delegate?.didConnect()
    }
    
    internal func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("WebsocketTransport websocketDidDisconnect")
        if error == nil {
            self.delegate?.didDisconnect(NSError(error: .lostConnection))
        } else {
            self.delegate?.didFailConnection(error)
        }
    }
    
    internal func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        self.delegate?.didReceiveMessage(text)
    }
    
    // MARK: TODO
    internal func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Cometd: Received data: \(data.count)")
        //self.socket.writeData(data)
    }
    
    // MARK: WebSocket Pong Delegate
    internal func websocketDidReceivePong(_ socket: WebSocket) {
        self.delegate?.didReceivePong()
    }
    
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        self.delegate?.didReceivePong()
    }
}

