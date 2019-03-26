//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BitfinexManager {
  let api = BitfinexWs()
  
  var bitfinexBook: [Double:Double] = [:] //[Price:Amount]
  
  init() {
    
    api.onePriceBookResponse = { response in
      self.didGet(price: response.priceSnapshot.price, amount: response.priceSnapshot.amount, count: response.priceSnapshot.count)
    }
    
    api.fullBookResponse = {  response in
      for priceLevel in response.prices {
        self.didGet(price: priceLevel.price, amount: priceLevel.amount, count: priceLevel.count)
      }
    }
    
  }
  
  func startCollectData() {
    api.start()
    
   
    
  }
  
  func didGet(price: Double, amount: Double, count:Int) {
    if count > 0 {
      if amount > 0 {
        bitfinexBook[price] = bitfinexBook[price] ?? 0 + amount
      } else if amount < 0 {
        bitfinexBook[-price] = bitfinexBook[-price] ?? 0 + abs(amount)
      } else {
        print("error, amount is:", amount)
      }
      
    }  else if count == 0 {
      if amount == 1 {
        bitfinexBook[price] = nil
      } else if amount == -1 {
        bitfinexBook[-price] = nil
      } else {
         print("error, amount is", amount)
      }
    } else {
      print("error, count is < 0")
    }
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
