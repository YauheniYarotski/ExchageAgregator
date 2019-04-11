//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs


class BitfinexManager: BaseExchangeManager {
  
  let restApi = BitfinexRest()
  
  override init() {
    super.init()
    let ws = BitfinexWs()
    ws.onePriceBookResponse = { response in
      self.updateBook(withPrice: response.priceSnapshot.price, amount: response.priceSnapshot.amount, count: response.priceSnapshot.count, pair: response.pair)
    }
    
    ws.fullBookResponse = {  response in
      for priceLevel in response.prices {
        self.updateBook(withPrice: priceLevel.price, amount: priceLevel.amount, count: priceLevel.count, pair: response.pair)
      }
    }
    api = ws
    
    
    restApi.didGetFullBook = { book in
      
      if let minBid = book.minBid, let maxAsk = book.maxAsk {
        self.removeOrders(fromMindBid: minBid.price, toMaxAsk: maxAsk.price, pair: book.pair)
      }
      
      for priceLevel in book.prices {
        self.updateBook(withPrice: priceLevel.price, amount: priceLevel.amount, count: priceLevel.count, pair: book.pair)
      }
    }
    
  }
  
  override func startCollectData() {
    super.startCollectData()
    
    Jobs.delay(by: .seconds(9), interval: .seconds(30)) {
      self.restApi.getFullBook(for: "BTCUSD")
    }
    
  }
  
  func updateBook(withPrice price: Double, amount: Double, count:Int, pair: String, deleteOldData: Bool = false) {
    var pairBook = deleteOldData ? [:] : book[pair] ?? [:]
    if count > 0 {
      if amount > 0 {
        pairBook[price] = amount
      } else if amount < 0 {
        pairBook[-price] = abs(amount)
      } else {
        print("error, amount is:", amount)
      }
      
    }  else if count == 0 {
      if amount == 1 {
        pairBook[price] = nil
      } else if amount == -1 {
        pairBook[-price] = nil
      } else {
        print("error, amount is", amount)
      }
    } else {
      print("error, count is < 0")
    }
    book[pair] = pairBook
  }
  
}

