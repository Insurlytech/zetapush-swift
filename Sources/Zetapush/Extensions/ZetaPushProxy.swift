//
//  ZetaPushProxy.swift
//  ZetaPush
//
//  Created by Anthony Guiguen on 19/04/2019.
//  Copyright © 2019 Leocare. All rights reserved.
//

import Foundation
import XCGLogger

/// This struct is used to make proxy between custom extension and real conformance object like UIButton or String
///
/// usage :
/// ```
/// extension ZetaPushProxy where Base == Int {
///   func square() -> Int {
///     return base * base // use base instead of self because it is the proxy between types
///   }
/// }
/// ```
public struct ZetaPushProxy<Base> {
  public var base: Base
  
  public init(_ base: Base) {
    self.base = base
  }
}

/// This protocol define the Type and Style of what you proxy looks like
/// here our prox y looks like `leo`
public protocol ZetaPushProxyCompatible {
  associatedtype CompatibleType
  
  var zp: CompatibleType { get }
}

/// This extension implement the protocol to define a default usage of our proxy
/// Here we check the Type of object that conform to LeocareProxyCompatible to inject inside our proxy
public extension ZetaPushProxyCompatible {
  var zp: ZetaPushProxy<Self> { return ZetaPushProxy(self) }
}

// All conformance here that your proxy will be available for
// and add conformance every time we implement our Proxy on new Type
extension XCGLogger: ZetaPushProxyCompatible { }
extension String: ZetaPushProxyCompatible { }
