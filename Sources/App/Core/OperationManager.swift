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
    let hb = HalfBook.init(pair: "BC", asks: [[5000,1]], bids: [[6000,1]])
    let ex = ExchangesBooks.init(exchangeName: "Bitfinf", books: [hb])
    Jobs.add(interval: .seconds(2)) {
      print("See you every 5 days.")
      
      self.sessionManager.update([ex])
    }
    
  
  }
}
