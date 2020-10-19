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
  private weak var recorder: ZetapushNetworkRecorder?
  
  // MARK: Lifecycle
  init(configuration: ServerConfiguration, recorder: ZetapushNetworkRecorder?) {
    self.url = URL(string: configuration.serverUrl)?.appendingPathComponent(configuration.sandboxId)
    self.recorder = recorder
    
    let timeout = configuration.timeout
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = timeout
    configuration.timeoutIntervalForResource = timeout * 3
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    if #available(iOS 11.0, *) {
      configuration.waitsForConnectivity = true
    }
    
    self.session = URLSession(configuration: configuration)
  }
  
  // MARK: Methods
  func fetchServersURLs(callback: @escaping (Result<[String], Error>) -> Void) {
    guard let url = url else {
      let error: ServerRemoteDataSourceError = .urlNotFound(url: self.url?.absoluteString ?? "")
      recorder?.record(error: error.toNSError())
      callback(.failure(error))
      return
    }
    task?.cancel()
    
    task = session.dataTask(with: url) { [weak self] data, response, error in
      defer { self?.task = nil }
      
      if let error = error {
        self?.recorder?.record(error: error as NSError)
        callback(.failure(error))
      } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
        let error: ServerRemoteDataSourceError = .response(response: response)
        self?.recorder?.record(error: error.toNSError())
        callback(.failure(error))
      } else if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if let servers = json?["servers"] as? [String] {
            callback(.success(servers))
          } else {
            let error: ServerRemoteDataSourceError = .serversNotFound
            self?.recorder?.record(error: error.toNSError())
            callback(.failure(error))
          }
        } catch let error {
          self?.recorder?.record(error: error as NSError)
          callback(.failure(error))
        }
      } else {
        let error: ServerRemoteDataSourceError = .unknown
        self?.recorder?.record(error: error.toNSError())
        callback(.failure(error))
      }
    }
    task?.resume()
  }
}
