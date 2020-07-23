//
//  ClientHelperError.swift
//  
//
//  Created by Anthony Guiguen on 22/07/2020.
//

import Foundation
import CometDClient

public enum ClientHelperError: Error {
  case connectionFailed(error: ServerRemoteDataSourceError)
  case connectionBroken(error: CometDClientError), connectionClosed(error: CometDClientError), handshakeFailed(error: CometDClientError), subscription(error: CometDClientError)
  
  public var code: String {
    switch self {
    case .connectionBroken(let error), .connectionClosed(let error), .handshakeFailed(let error), .subscription(let error): return error.code
    case .connectionFailed(let error): return error.code
    }
  }
  
  public func toNSError() -> NSError {
    switch self {
    case .connectionBroken(let error), .connectionClosed(let error), .handshakeFailed(let error), .subscription(let error): return error.toNSError()
    case .connectionFailed(let error): return error.toNSError()
    }
  }
}
