//
//  Logger+tags.swift
//  ZetaPush
//
//  Created by Anthony Guiguen on 19/04/2019.
//  Copyright © 2019 ZetaPush. All rights reserved.
//

import XCGLogger

fileprivate let userInfo = [XCGLogger.Constants.userInfoKeyTags: "zetapush"]

public extension ZetaPushProxy where Base == XCGLogger {
  func error(_ string: Any) {
    base.error(string, userInfo: userInfo)
  }
  
  func debug(_ string: Any) {
    base.debug(string, userInfo: userInfo)
  }
  
  func verbose(_ string: Any) {
    base.verbose(string, userInfo: userInfo)
  }
}
