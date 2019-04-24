//
//  ZetaPushMacroPublisher.swift
//  ZetaPush
//
//  Created by Leocare on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import Gloss

/*
 Class used as a base class for specific MacroPublisher
 */
// MARK: - ZetaPushMacroPublisher
open class ZetaPushMacroPublisher {
  // MARK: Properties
  public let clientHelper: ClientHelper
  public var zetaPushMacroService: ZetaPushMacroService
  
  // MARK: Lifecycle
  public init(_ clientHelper: ClientHelper, deploymentId: String) {
    self.clientHelper = clientHelper
    self.zetaPushMacroService = ZetaPushMacroService(clientHelper, deploymentId: deploymentId)
  }
  
  public convenience init(_ clientHelper: ClientHelper) {
    self.init(clientHelper, deploymentId: zetaPushDefaultConfig.macroDeployementId)
  }
}
