//
//  File.swift
//  
//
//  Created by Anthony Guiguen on 22/07/2020.
//

import Foundation

enum ErrorConstant {
  static let domain = "zetaPushNetwork"
  static let code = "code"
}

public enum ServerRemoteDataSourceError: Error {
  case canNotOpenURL(url: String), response(response: HTTPURLResponse), unknown, serversNotFound, failed(error: Error)
  
  var code: String {
    switch self {
    case .canNotOpenURL:
      return "ERROR_CLIENT_HELPER_CAN_NOT_OPEN_URL"
    case .response:
      return "ERROR_CLIENT_HELPER_RESPONSE"
    case .unknown:
      return "ERROR_CLIENT_HELPER_UNKNOWN"
    case .serversNotFound:
      return "ERROR_CLIENT_HELPER_SERVERS_NOT_FOUND"
    case .failed:
      return ""
    }
  }
  
  func toNSError() -> NSError {
    switch self {
    case .canNotOpenURL(let url):
      return NSError(domain: ErrorConstant.domain, code: 403, userInfo: [
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Can not open URL", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Can not open this url : \(url).", comment: ""),
        ErrorConstant.code: code
      ])
    case .response(let response):
      return NSError(domain: ErrorConstant.domain, code: response.statusCode, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("The request failed.", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("The fetchServersURLs(callback:) response returned a \(response.statusCode).", comment: ""),
        ErrorConstant.code: code
      ])
    case .failed(let error):
      return error as NSError
    case .serversNotFound:
      return NSError(domain: ErrorConstant.domain, code: 404, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Empty list of server.", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("The fetchServersURLs(callback:) response has an empty list of server.", comment: ""),
        ErrorConstant.code: code
      ])
    case .unknown:
      return NSError(domain: ErrorConstant.domain, code: 456, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Ooops an error occured", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Unknown error", comment: ""),
        ErrorConstant.code: code
      ])
    }
  }
}
