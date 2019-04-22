//
//  BaseWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/15/19.
//

import Foundation
import Vapor
import WebSocket

class BaseWs {
  
  weak var ws: WebSocket? {
    didSet {
      guard let ws = ws else {return}
      ws.onCloseCode { (code) in
        print("closing ws \(self) with code:",code)
      }
      ws.onError { (ws, error) in
        print("error from ws \(self)",error)
      }
    }
  }
  
  func stopListenTickers() {
    self.ws?.close(code: WebSocketErrorCode.normalClosure)
  }
  
}

