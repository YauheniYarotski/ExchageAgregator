//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BitfinexManager: BaseExchangeManager {
  
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
  }

  func updateBook(withPrice price: Double, amount: Double, count:Int, pair: String) {
    var pairBook = book[pair] ?? [:]
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
//        print("remove bids:", price)
        pairBook[price] = nil
      } else if amount == -1 {
//        print("remove ask:", price)
        pairBook[-price] = nil
      } else {
         print("error, amount is", amount)
      }
    } else {
      print("error, count is < 0")
    }
    book[pair] = pairBook
//    print(pairBook)
//    print("bids",pairBook.filter({$0.key > 0}).count)
//    print("asks",pairBook.filter({$0.key < 0}).count)
  }
  
}

