//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BitstampManager: BaseExchangeManager {
  
  override init() {
    super.init()
    let ws = BitstampWs()
    ws.bookResponse = {  response in
      self.updateBook(asks: response.data.asks, bids: response.data.bids, pair: response.symbol)
    }
    api = ws
  }
  
  
  func updateBook(asks: [[Double]], bids: [[Double]], pair: String) {
    var pairBook = book[pair] ?? [:]
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

