//
//  BitstampRest.swift
//  App
//
//  Created by Yauheni Yarotski on 4/9/19.
//

import Foundation
import Vapor

class BitstampRest {
  
  let hostname = "www.bitstamp.net"
  let apiOrderBook = "/api/v2/order_book/"
  
  var didGetFullBook: ((_ bookResponse: BitstampBookData, _ pair: BitstampPair)->())?
  
  func getFullBook(for pair: BitstampPair) {
    
    let httpReq = HTTPRequest(method: .GET, url: apiOrderBook + pair.urlSymbol)
    
    let _ = HTTPClient.connect(scheme: .https, hostname: hostname, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ response in
        if let data = response.body.data, let bookResponse = try? JSONDecoder().decode(BitstampBookData.self, from: data) {
          self.didGetFullBook?(bookResponse, pair)
        } else {
          print("Error parsing Bitstamp response:",httpReq)
        }
      }).catch({ (error) in
        print("Error:",error)
      })
      }
    
    
    
  }
}

