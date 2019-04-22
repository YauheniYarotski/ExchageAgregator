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
  let agregator = Agregator()
  
  init() {
    agregator.booksSourceHandler = {self.exchangeManager.getExchangesBooks()}
  }
  
  func start(_ app: Application) {
    
    exchangeManager.startCollectData()
    
    Jobs.add(interval: .seconds(1)) {      
      if let granulatedExchanges = self.agregator.getData(granulation: 50) {
        self.sessionManager.update(granulatedExchanges)
      }
    }
    
    
  }
}
