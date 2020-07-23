//
//  ServerRemoteDataSource.swift
//  
//
//  Created by Anthony Guiguen on 22/07/2020.
//

import Foundation
import UIKit

public struct ServerConfiguration {
  var serverUrl: String
  let sandboxId: String
  var timeout: TimeInterval
}

class ServerRemoteDataSource {
  
  // MARK: Properties
  private let url: URL?
  private let session: URLSession!
  private var task: URLSessionDataTask?
  
  // MARK: Lifecycle
  init(configuration: ServerConfiguration) {
    self.url = URL(string: configuration.serverUrl)?.appendingPathComponent(configuration.sandboxId)
    
    let timeout = configuration.timeout
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = timeout
    configuration.timeoutIntervalForResource = timeout * 3
    
    self.session = URLSession(configuration: configuration)
  }
  
  // MARK: Methods
  func fetchServersURLs(callback: @escaping (Result<[String], ServerRemoteDataSourceError>) -> Void) {
    guard let url = url, UIApplication.shared.canOpenURL(url) else {
      callback(.failure(.canNotOpenURL(url: self.url?.absoluteString ?? "")))
      return
    }
    task?.cancel()
    
    task = session.dataTask(with: url) { [weak self] data, response, error in
      defer { self?.task = nil }
      
      if let error = error {
        callback(.failure(.failed(error: error)))
      } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
        callback(.failure(.response(response: response)))
      } else if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if let servers = json?["servers"] as? [String] {
            callback(.success(servers))
          } else {
            callback(.failure(.serversNotFound))
          }
        } catch let error {
          callback(.failure(.failed(error: error)))
        }
      } else {
        callback(.failure(.unknown))
      }
    }
    task?.resume()
  }
}
