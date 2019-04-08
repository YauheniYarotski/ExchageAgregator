//
//  ExchangesManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/7/19.
//

import Foundation



class ExchangesManager {
  
  let bitfinexManager = BitfinexManager()
  let binanceManager = BinanceManager()
  let bitstampManager = BitstampManager()
  
  var exchangesBooks = [String:[String:[Double:Double]]]() //[exhange:[pair:[price:amount]]]
  
  init() {
    bitfinexManager.bookDidUpdate = {bitfinexBook in
      self.updateBook(exchangeName: "Bitfinex", book: bitfinexBook)
    }
    binanceManager.bookDidUpdate = {book in
      self.updateBook(exchangeName: "Binance", book: book)
    }
    bitstampManager.bookDidUpdate = {book in
      self.updateBook(exchangeName: "Bitstamp", book: book)
    }
  }
  
  func startCollectData() {
    bitfinexManager.startCollectData()
    binanceManager.startCollectData()
    bitstampManager.startCollectData()
  }
  
  func updateBook(exchangeName: String, book: [String:[Double:Double]]) {
    exchangesBooks[exchangeName] = book
  }
}
