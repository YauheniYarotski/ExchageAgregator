//
//  ExchangesManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/7/19.
//

import Foundation
import Vapor


class ExchangesManager {
  
  let bitfinexManager = BitfinexManager()
  let binanceManager = BinanceManager()
  //  let bitstampManager = BitstampManager()
  //  let coinbaseProManager = CoinbaseProManager()
  
  var exchangesBooks = [ExchangeName:[CoinPair:[Double:Double]]]()
  
  init() {
    bitfinexManager.booksDidUpdate = { newBook in
      newBook.forEach({ (pairBook) in
        let coinPair = CoinPair(firstAsset: pairBook.key.firstAsset.symbol, secondAsset: pairBook.key.secondAsset.symbol)
        self.updateBook(exchangeName: .bitfinex, book: pairBook.value, pair: coinPair)
      })
    }
    binanceManager.booksDidUpdate = { newBook in
      newBook.forEach({ (pairBook) in
        let coinPair = CoinPair(firstAsset: pairBook.key.firstAsset.rawValue, secondAsset: pairBook.key.secondAsset.rawValue)
        self.updateBook(exchangeName: .binance, book: pairBook.value, pair: coinPair)
      })
    }
    //    bitstampManager.bookDidUpdate = {book in
    //      self.updateBook(exchangeName: "Bitstamp", book: book)
    //    }
    //
    //    coinbaseProManager.bookDidUpdate = {book in
    //      self.updateBook(exchangeName: "CoinbasePro", book: book)
    //    }
  }
  
  func startCollectData() {
    bitfinexManager.startListenBooks()
    binanceManager.startListenBooks()
    //    bitstampManager.startCollectData()
    //    coinbaseProManager.startCollectData()
  }
  
  func updateBook(exchangeName: ExchangeName, book: [Double:Double], pair: CoinPair) {
    if exchangesBooks[exchangeName] != nil {
      exchangesBooks[exchangeName]?[pair] = book
    } else {
      exchangesBooks[exchangeName] = [pair:book]
    }
  }
}


enum ExchangeName: String, Content {
  case binance = "Binance"
  case bitfinex = "Bitfinex"
  case bitstamp = "Bitstamp"
  case coinbasePro = "CoinbasePro"
  case poloniex = "Poloniex"
}
