//
//  OperationManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/6/19.
//

import Foundation
import Vapor
import Jobs

class OperationManager {
  
  let exchangeManager = ExchangesManager()
  let sessionManager = TrackingSessionManager()

  
  func start(_ app: Application) {
      self.exchangeManager.startCollectData()
    
    Jobs.add(interval: .seconds(1)) {
//      print("See you every 5 days.")
      var exchanges = [ExchangesBooks]()
      
      for exchange in self.exchangeManager.exchangesBooks  {
        var books = [HalfBook]()
        
        for pair in exchange.value {
          let sorteredPrices = pair.value.sorted(by: {$0.0 > $1.0})
          var asks = [[Double]]()
          var bids = [[Double]]()
          var totalAsks: Double = 0
          var totalBids: Double = 0
          for levelPrice in sorteredPrices {
            if levelPrice.key < 0 {
              asks.append([-levelPrice.key,levelPrice.value.rounded(toPlaces:3)])
              totalAsks = (totalAsks + levelPrice.value).rounded(toPlaces:3)
            } else {
              bids.append([levelPrice.key,levelPrice.value.rounded(toPlaces:3)])
              totalBids = (totalBids + levelPrice.value).rounded(toPlaces:3)
            }
          }
          
          let hb = HalfBook.init(pair: pair.key, asks: asks, bids: bids, totalAsks: totalAsks, totalBids: totalBids)
          books.append(hb)
        }
        
        let ex = ExchangesBooks.init(exchangeName: exchange.key, books: books)
        exchanges.append(ex)
      }
      
      self.sessionManager.update(exchanges)
    }
    
  
  }
}
