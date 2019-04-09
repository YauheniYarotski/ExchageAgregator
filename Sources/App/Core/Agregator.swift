//
//  Agregator.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//


import Foundation
import Vapor

class Agregator {
  
  let exchangeManager: ExchangesManager
  
  init(exchangeManager: ExchangesManager) {
    self.exchangeManager = exchangeManager
  }
  
  func getData(granulation: Double) -> [ExchangesBooks] {
    var exchanges = [ExchangesBooks]()
    
    for exchange in self.exchangeManager.exchangesBooks  {
      var booksForPairs = [BookForPair]()
      
      for pair in exchange.value {
        var asks = [Double:Double]()
        var bids = [Double:Double]()
        var totalAsks: Double = 0
        var totalBids: Double = 0
        for levelPrice in pair.value {
          let price = levelPrice.key.granulate(toGranulation: granulation)
          let amount = levelPrice.value
          if price < 0 {
            asks[-price] =  (asks[-price] ?? 0) + amount
            totalAsks = totalAsks + amount
          } else {
            bids[price] =  (bids[price] ?? 0) + amount
            totalBids = totalBids + amount
            
            
          }
        }
        
        let sorteredAsks = asks.sorted(by: {$0.0 < $1.0}).map({[$0.key.rounded(toPlaces: 2),$0.value.rounded(toPlaces: 2)]})
        let sorteredBids = bids.sorted(by: {$0.0 > $1.0}).map({[$0.key.rounded(toPlaces: 2),$0.value.rounded(toPlaces: 2)]})
        
        let bookForPair = BookForPair.init(pair: pair.key, asks: sorteredAsks, bids: sorteredBids, totalAsks: totalAsks.rounded(toPlaces:3), totalBids: totalBids.rounded(toPlaces:3))
        booksForPairs.append(bookForPair)
      }
      let sorteredBooksForPairs = booksForPairs.sorted(by: {$0.pair > $1.pair})
      let ex = ExchangesBooks.init(exchangeName: exchange.key, books: sorteredBooksForPairs)
      exchanges.append(ex)
    }
    return exchanges.sorted(by: {$0.exchangeName > $1.exchangeName})
  }
  
}

