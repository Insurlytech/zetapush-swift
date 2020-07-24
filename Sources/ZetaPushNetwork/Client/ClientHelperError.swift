//
//  ClientHelperError.swift
//  
//
//  Created by Anthony Guiguen on 22/07/2020.
//

import Foundation
import CometDClient

public typealias HandshakeError = CometDClient.HandshakeError

public enum ClientHelperError: Error {
  case connectionFailed, connectionBroken, connectionClosed, handshakeFailed(reason: HandshakeError?), subscription
}
