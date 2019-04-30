//
//  Promise+Timeout.swift
//  ZetaPushSwift
//
//  Created by Anthony Guiguen on 24/04/2019.
//  Copyright © 2019 ZetaPush. All rights reserved.
//

import PromiseKit

extension Promise {
  /// Allow Promise to be cancellable after a delay. If this delay is reached an error occurs.
  ///
  /// - Parameter seconds: define the timeout delay after throw an error : ZetaPushMacroError.timeout
  /// - Returns: a Promise that handle the timeout
  func timeout(after seconds: TimeInterval) -> Promise<T> {
    return race(asVoid(), after(seconds: seconds).done {
      throw ZetaPushMacroError.timeout
    }).compactMap {
      self.value
    }
  }
  
  /// Allow Promise to be retryable a certain number of time with a delay
  ///
  /// - Parameters:
  ///   - times: number of times you want to retry this Promise
  ///   - cooldown: the delay between two retry
  /// - Returns: a Promise that handle retry
  func retry(times: Int, cooldown: TimeInterval) -> Promise<T> {
    var retryCounter = 0
    func attempt() -> Promise<T> {
      return self.recover(policy: CatchPolicy.allErrorsExceptCancellation) { error -> Promise<T> in
        retryCounter += 1
        guard retryCounter <= times else {
          throw error
        }
        return after(seconds: cooldown).then(attempt)
      }
    }
    return attempt()
  }
}
