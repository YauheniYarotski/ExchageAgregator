//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BinanceManager {
  let api = BinanceWs()
  
  var binanceBook: [String:[Double:Double]] = [:] { //[pair:[Price:Amount]]
    didSet {
      bookDidUpdate?(binanceBook)
    }
  }
  var bookDidUpdate: ((_ bitfinexBook: [String:[Double:Double]])->())?
  
  init() {
    api.bookResponse = {  response in
      self.updateBook(asks: response.asks, bids: response.bids, pair: response.symbol)
    }
  }
  
  func startCollectData() {
    api.start()
  }
  
  func updateBook(asks: [[Double]], bids: [[Double]], pair: String) {
    var pairBook = binanceBook[pair] ?? [:]
    for bid in bids {
      let price = bid[0]
      let amount = bid[1]
      if amount > 0 {
        pairBook[price] = pairBook[price] ?? 0 + amount
      } else {
        pairBook[price] = nil
      }
    }
    
    for ask in asks {
      let price = -ask[0]
      let amount = ask[1]
      if amount > 0 {
        pairBook[price] = pairBook[price] ?? 0 + amount
      } else {
        pairBook[price] = nil
      }
    }
    
    binanceBook[pair] = pairBook
    
//    print("bids",pairBook.filter({$0.key > 0}).count)
//    print("asks",pairBook.filter({$0.key < 0}).count)
  }
  
}

