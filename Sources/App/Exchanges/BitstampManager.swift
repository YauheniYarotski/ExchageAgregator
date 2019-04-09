//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs


class BitstampManager: BaseExchangeManager {
  
  let restApi = BitstampRest()
  
  override init() {
    super.init()
    let ws = BitstampWs()
    ws.bookResponse = {  response in
      self.updateBook(asks: response.data.asks, bids: response.data.bids, pair: response.symbol)
    }
    api = ws
    
    restApi.didGetFullBook = { book, pair in
      self.updateBook(asks: book.asks, bids: book.bids, pair: pair, deleteOldData: true)
    }
  }
  
  override func startCollectData() {
    super.startCollectData()
    
    Jobs.delay(by: .seconds(6), interval: .seconds(30)) {
       self.restApi.getFullBook(for: "btcusd")
    }
   
  }
  
  
  func updateBook(asks: [[Double]], bids: [[Double]], pair: String, deleteOldData: Bool = false) {
    
    var pairBook = deleteOldData ? [:] : book[pair] ?? [:]
    for bid in bids {
      let price = bid[0]
      let amount = bid[1]
      if amount > 0 {
        pairBook[price] = amount
      } else {
        pairBook[price] = nil
      }
    }
    
    for ask in asks {
      let price = -ask[0]
      let amount = ask[1]
      if amount > 0 {
        pairBook[price] = amount
      } else {
        pairBook[price] = nil
      }
    }
    
    book[pair] = pairBook
    
//    print("bids",pairBook.filter({$0.key > 0}).count)
//    print("asks",pairBook.filter({$0.key < 0}).count)
  }
  
}

