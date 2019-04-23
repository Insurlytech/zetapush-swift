//
//  ZetaPushServicePublisher.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import Gloss

/*
 Class used as a base class for specific ServicePublisher
 */
// MARK: - ZetaPushServicePublisher
open class ZetaPushServicePublisher {
  // MARK: Properties
  public var clientHelper: ClientHelper?
  public var zetaPushService: ZetaPushService
  
  // MARK: Lifecycle
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.zetaPushService = ZetaPushService(clientHelper, deploymentId: deploymentId)
  }
}
