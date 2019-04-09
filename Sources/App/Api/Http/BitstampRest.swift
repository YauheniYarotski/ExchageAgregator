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
  
  var didGetFullBook: ((_ bookResponse: BitstampBookData, _ pair: String)->())?
  
  func getFullBook(for pair: String) {
    
    let httpReq = HTTPRequest(method: .GET, url: apiOrderBook + pair)
    
    let _ = HTTPClient.connect(scheme: .https, hostname: hostname, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ response in
        if let data = response.body.data, let bookResponse = try? JSONDecoder().decode(BitstampBookData.self, from: data) {
          self.didGetFullBook?(bookResponse, pair)
        }
      })
    }
    
    
    
  }
}

