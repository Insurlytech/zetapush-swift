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
  case canNotOpenURL(url: String), response(response: HTTPURLResponse), serversNotFound, unknown
  
  func toNSError() -> NSError {
    switch self {
    case .canNotOpenURL(let url):
      return NSError(domain: ErrorConstant.domain, code: 403, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Can not open URL", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Can not open this url : \(url).", comment: ""),
        ErrorConstant.code: "ERROR_CLIENT_HELPER_CAN_NOT_OPEN_URL"
      ])
    case .response(let response):
      return NSError(domain: ErrorConstant.domain, code: response.statusCode, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("The request failed.", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("The fetchServersURLs(callback:) response returned a \(response.statusCode).", comment: ""),
        ErrorConstant.code: "ERROR_CLIENT_HELPER_RESPONSE"
      ])
    case .serversNotFound:
      return NSError(domain: ErrorConstant.domain, code: 404, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Empty list of server.", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("The fetchServersURLs(callback:) response has an empty list of server.", comment: ""),
        ErrorConstant.code: "ERROR_CLIENT_HELPER_SERVERS_NOT_FOUND"
      ])
    case .unknown:
      return NSError(domain: ErrorConstant.domain, code: 456, userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString("Ooops an error occured", comment: ""),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString("Unknown error", comment: ""),
        ErrorConstant.code: "ERROR_CLIENT_HELPER_UNKNOWN"
      ])
    }
  }
}
