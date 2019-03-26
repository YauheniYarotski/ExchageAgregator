//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BitfinexManager {
  let api = BitfinexWs()
  
  func startCollectData() {
    api.start()
  }
}
