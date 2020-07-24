//
//  ZetapushNetworkRecorder.swift
//  
//
//  Created by Anthony Guiguen on 24/07/2020.
//

import CometDClient
import Foundation

/// Implement  this protocol if you want to catch precise error for analytics or debug
public protocol ZetapushNetworkRecorder: CometDClientRecorder { }
