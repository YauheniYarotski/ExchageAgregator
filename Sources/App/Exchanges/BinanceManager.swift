//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs

class BinanceManager: BaseExchangeManager {
  
  let restApi = BinanceRest()
  
  override init() {
    super.init()
    let ws = BinanceWs()
    ws.bookResponse = {  response in
      self.updateBook(asks: response.asks, bids: response.bids, pair: response.symbol)
    }
    api = ws
    
    restApi.didGetFullBook = { book, pair in
      //1) rest gets only 1000 prices, but in book more, so, reload only from min to max
      if let minBid = book.minBid, minBid.count == 2, let maxAsk = book.maxAsk, maxAsk.count == 2 {
        let minBidPrice = minBid[0]
        let maxAskPrice = maxAsk[0]
        self.removeOrders(fromMindBid: minBidPrice, toMaxAsk: maxAskPrice, pair: pair)
      }
      self.updateBook(asks: book.asks, bids: book.bids, pair: pair)
    }
  }
  
  override func startCollectData() {
    super.startCollectData()
    
    Jobs.delay(by: .seconds(5), interval: .seconds(30)) {
      self.restApi.getFullBook(for: "BTCUSDT")
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
  }
  
}

