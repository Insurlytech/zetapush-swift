//
//  Promise+Timeout.swift
//  ZetaPush
//
//  Created by Anthony Guiguen on 24/04/2019.
//  Copyright © 2019 ZetaPush. All rights reserved.
//

import PromiseKit
import Foundation

extension Promise {
  func timeout(after seconds: TimeInterval) -> Promise<T> {
    return race(asVoid(), after(seconds: seconds).done {
      throw ZetaPushMacroError.timeout
    }).compactMap {
      self.value
    }
  }
}
