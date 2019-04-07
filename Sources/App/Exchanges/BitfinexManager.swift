//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BitfinexManager {
  let api = BitfinexWs()
  
  var bitfinexBook: [String:[Double:Double]] = [:] { //[pair:[Price:Amount]]
    didSet {
      bookDidUpdate?(bitfinexBook)
    }
  }
  var bookDidUpdate: ((_ bitfinexBook: [String:[Double:Double]])->())?
  
  init() {
    
    api.onePriceBookResponse = { response in
      self.updateBook(withPrice: response.priceSnapshot.price, amount: response.priceSnapshot.amount, count: response.priceSnapshot.count, pair: response.pair)
    }
    
    api.fullBookResponse = {  response in
      for priceLevel in response.prices {
        self.updateBook(withPrice: priceLevel.price, amount: priceLevel.amount, count: priceLevel.count, pair: response.pair)
      }
    }
    
  }
  
  func startCollectData() {
    api.start()
  }
  
  func updateBook(withPrice price: Double, amount: Double, count:Int, pair: String) {
    var pairBook = bitfinexBook[pair] ?? [:]
    if count > 0 {
      if amount > 0 {
        pairBook[price] = pairBook[price] ?? 0 + amount
      } else if amount < 0 {
        pairBook[-price] = pairBook[-price] ?? 0 + abs(amount)
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
    bitfinexBook[pair] = pairBook
    
//    print("bids",pairBook.filter({$0.key > 0}).count)
//    print("asks",pairBook.filter({$0.key < 0}).count)
  }
  
}


//
//class BitfinexBook {
//  var price: Double
//  var amount: Double
//
//  init(price: Double, amount: Double) {
//    self.price = price
//    self.amount = amount
//  }
//
//}
