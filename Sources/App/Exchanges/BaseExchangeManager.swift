//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BaseExchangeManager {
  
  var api: Startable?
  
  var book: [String:[Double:Double]] = [:] { //[pair:[Price:Amount]]
    didSet {
      bookDidUpdate?(book)
    }
  }
  var bookDidUpdate: ((_ book: [String:[Double:Double]])->())?
  
  func startCollectData() {
    api?.start()
  }
  
  
  
}

