//
//  ExchangesManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/7/19.
//

import Foundation

//struct ExchangesBooks: Content {
//  let exchangeName: String
//  let books: [HalfBook]
//}
//
//struct HalfBook: Content {
//  let pair: String
//  let asks: [[Double]]
//  let bids: [[Double]]
//}


class ExchangesManager {
  
  let bitfinexManager = BitfinexManager()
  
  var exchangesBooks = [String:[String:[Double:Double]]]() //[exhange:[pair:[price:amount]]]
  
  init() {
    bitfinexManager.bookDidUpdate = {bitfinexBook in
      self.updateBook(exchangeName: "Bitfinex", book: bitfinexBook)
    }
  }
  
  func startCollectData() {
    bitfinexManager.startCollectData()
  }
  
  func updateBook(exchangeName: String, book: [String:[Double:Double]]) {
    var exchnageBook = exchangesBooks[exchangeName] ?? [String:[Double:Double]]()
    for newPairBook in book {
      var pairBook = exchnageBook[newPairBook.key] ?? [:]
      for priceLevel in newPairBook.value {
        pairBook[priceLevel.key] = pairBook[priceLevel.key] ?? 0 + priceLevel.value
      }
      exchnageBook[newPairBook.key] = pairBook
    }
    exchangesBooks[exchangeName] = exchnageBook
  }
}
