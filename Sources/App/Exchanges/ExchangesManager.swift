//
//  ExchangesManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/7/19.
//

import Foundation



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
    exchangesBooks[exchangeName] = book
  }
}
