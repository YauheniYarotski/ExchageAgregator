//
//  ExchangesManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/7/19.
//

import Foundation
import Vapor


class ExchangesManager {
  
  static var typeName: String { return String(describing: self) }
  
  private let serialQueue = DispatchQueue.init( label: "queue \(typeName)")
  
  let bitfinexManager = BitfinexManager()
  let binanceManager = BinanceManager()
  //  let bitstampManager = BitstampManager()
  //  let coinbaseProManager = CoinbaseProManager()
  
  private var exchangesBooks = [ExchangeName:[CoinPair:[Double:Double]]]()
  
  func getExchangesBooks() -> [ExchangeName:[CoinPair:[Double:Double]]] {
    var copy: [ExchangeName:[CoinPair:[Double:Double]]]!
    serialQueue.sync {
      copy = self.exchangesBooks
    }
    return copy
  }
  
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
    serialQueue.async {
      if self.exchangesBooks[exchangeName] != nil {
        self.exchangesBooks[exchangeName]?[pair] = book
      } else {
        self.exchangesBooks[exchangeName] = [pair:book]
      }
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
