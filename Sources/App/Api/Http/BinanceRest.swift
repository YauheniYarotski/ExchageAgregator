//
//  BitstampRest.swift
//  App
//
//  Created by Yauheni Yarotski on 4/9/19.
//

import Foundation
import Vapor

class BinanceRest {
  
  var didGetFullBook: ((_ bookResponse: BinanceBookRestResponse, _ pair: String)->())?
  
  func getFullBook(for pair: String) {
    
    var components = URLComponents()
    components.path = "/api/v1/depth"
    let queryItemLimit = URLQueryItem(name: "limit", value: "1000")
    let queryItemSymbol = URLQueryItem(name: "symbol", value: pair)
    components.queryItems = [queryItemLimit, queryItemSymbol]
    

    
    let httpReq = HTTPRequest(method: .GET, url: components.url!.absoluteString)
    let _ = HTTPClient.connect(scheme: .https, hostname: "api.binance.com", on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ response in
        if let data = response.body.data, let bookResponse = try? JSONDecoder().decode(BinanceBookRestResponse.self, from: data) {
          self.didGetFullBook?(bookResponse, pair)
        } else {
          print("error parsing json:", response.body)
        }
      }).catch({ (error) in
        print("err:",error)
      })
      }.catch { (error) in
        print("err:",error)
    }
    
    
    
  }
}

struct BinanceBookRestResponse: Content {
  
  let lastUpdateId: Int
  let bids: [[Double]]
  let asks: [[Double]]
  
  var maxAsk: [Double]? {
    return asks.max(by: {$0[0] < $1[0]})
  }
  var minBid: [Double]? {
    return bids.max(by: {$0[0] > $1[0]})
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    lastUpdateId = try container.decode(Int.self, forKey: .lastUpdateId)
    bids = try container.decode([[String]].self, forKey: .bids).compactMap({$0.compactMap({Double($0)})})
    asks = try container.decode([[String]].self, forKey: .asks).compactMap({$0.compactMap({Double($0)})})
  }
}



//    let _ = HTTPClient.connect(scheme: .https, hostname: hostname, on: wsClientWorker).map({ client in
//      client.send(httpReq).map { response in
////        print(response.body)
//
//        if let data = response.body.data, let bookResponse = try? JSONDecoder().decode(BitstampBookData.self, from: data) {
//                self.didGetFullBook?(bookResponse)
//              }
//        return response
//      }
//    })

//    HTTPClient.connect(scheme: .https, hostname: hostname, on: wsClientWorker).map { (client) -> (HTTPClient) in
//      print(client)
//      return client
//    }

//    let resp = HTTPClient.connect(scheme: .https, hostname: hostname, on: wsClientWorker)
//      .flatMap(to: BitstampBookData.self) { client in
//      return client.send(httpReq)
//        .map(to: BitstampBookData.self) { response in
//          let data = response.body.data!
//          let bookResponse = try! JSONDecoder().decode(BitstampBookData.self, from: data)
////                            self.didGetFullBook?(bookResponse)
////                          }
//          return bookResponse
//        }
//    }
