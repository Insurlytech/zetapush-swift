//
//  CometdSocketError.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//
// Adapted from https://github.com/hamin/FayeSwift

import Foundation

// MARK: - CometdSocketError
public enum CometdSocketError: Error {
  case lostConnection
  case transportWrite
}
