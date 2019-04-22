//
//  BitstampRest.swift
//  App
//
//  Created by Yauheni Yarotski on 4/9/19.
//

import Foundation
import Vapor

class BitfinexRest {
  
  let hostname = "api-pub.bitfinex.com"
  let secondHostName = "api.bitfinex.com"
  let apiOrderBook = "/v2/book/t"
  let apiPairs = "/v1/symbols"
  
  var didGetFullBook: ((_ bookResponse: BitfinexBookAllPricesSnapshotResponse)->())?
  var didGetPairs: ((_ reposen: [String])->())?
  
  func getFullBook(for pair: String) {
    
    let httpReq = HTTPRequest(method: .GET, url: apiOrderBook + pair + "/P2")
    
    let _ = HTTPClient.connect(scheme: .https, hostname: hostname, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ response in
        
        //if let bookResponse: BitstampBookResponse = try? JSONDecoder().decode(BitstampBookResponse.self, from: jsonData)
        //geting snap of all prices or single snape
        if let jsonData = response.body.data,
          let parsedAny = try? JSONSerialization.jsonObject(with:
            jsonData, options: []),
          let draftPricesSnap = parsedAny as? [[Double]],
          draftPricesSnap.count > 0 {
          var pricesSnapshor = [BitfinexBookPrice]()
          for draftPriceSnap in draftPricesSnap {
            let priceSnap = BitfinexBookPrice(price: draftPriceSnap[0], count: Int(draftPriceSnap[1]), amount: draftPriceSnap[2])
            pricesSnapshor.append(priceSnap)
          }
          let bitfinexBookAllPricesSnapshotResponse = BitfinexBookAllPricesSnapshotResponse.init(chanId: -99, prices: pricesSnapshor, pair: pair)
          self.didGetFullBook?(bitfinexBookAllPricesSnapshotResponse)
        } else {
          print("\(self), annown answer from server", response.body)
        }
        
      })
    }
    
    
    
  }
  
  func getPairs() {
    let httpReq = HTTPRequest(method: .GET, url: apiPairs)
    let _ = HTTPClient.connect(scheme: .https, hostname: secondHostName, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ response in
        
        if let jsonData = response.body.data,
          let parsedAny = try? JSONSerialization.jsonObject(with:
            jsonData, options: []),
          let pairs = parsedAny as? [String],
          pairs.count > 0 {
          self.didGetPairs?(pairs)
        } else {
          print("\(self), annown answer from server", response.body)
        }
      })
    }
  }
}

