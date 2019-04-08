//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket
import ObjectMapper

class BinanceWs: Startable {
  
  var bookResponse: ((_ binanceBookResponse: BinanceBookResponse)->())?
  
  func start() {
    
//    let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    guard let ws = try? HTTPClient.webSocket(scheme: .wss, hostname: "stream.binance.com",port: 9443, path: "/ws/btcusdt@depth", on: wsClientWorker).wait() else {
      print("BinanceWS is nil")
      return
    }
    
    ws.onText { ws, text in
      //      print(text)
      if let jsonData = text.data(using: .utf8), let binanceBookResponse: BinanceBookResponse = try? JSONDecoder().decode(BinanceBookResponse.self, from: jsonData) {
        self.bookResponse?(binanceBookResponse)
      } else {
        print("Error with parsing binance ws response")
        return
      }
      
    }
    
  }
  
}





// {
// "e": "depthUpdate", // Event type
// "E": 123456789,     // Event time
// "s": "BNBBTC",      // Symbol
// "U": 157,           // First update ID in event
// "u": 160,           // Final update ID in event
// "b": [              // Bids to be updated
// [
// "0.0024",       // Price level to be updated
// "10"            // Quantity
// ]
// ],
// "a": [              // Asks to be updated
// [
// "0.0026",       // Price level to be updated
// "100"           // Quantity
// ]
// ]
// }
//
// {"e":"depthUpdate",
// "E":1554705395676,
// "s":"BTCUSDT",
// "U":491907148,
// "u":491907192,
// "b":[["5228.02000000","0.03824500"],["5228.01000000","5.44879100"],["5227.80000000","0.00000000"],["5225.81000000","0.00000000"],["5225.79000000","0.00000000"],["5225.67000000","0.11483400"],["5225.65000000","0.38586400"],["5225.64000000","0.00000000"],["5225.51000000","0.94172600"],["5224.77000000","0.00000000"],["5220.30000000","0.00000000"],["5220.22000000","0.00000000"],["5218.16000000","0.05580000"],["5215.42000000","2.00000000"],["5001.00000000","5.53938200"]],
// "a":[["5229.41000000","0.03824400"],["5229.42000000","0.80000000"],["5229.43000000","0.00000000"],["5229.44000000","0.00000000"],["5233.20000000","0.50000000"],["5239.32000000","0.05671000"],["5239.60000000","0.11470000"],["5239.99000000","0.00000000"]]}
//

//let product: Product = try! JSONDecoder().decode(Product.self, for: data)
struct BinanceBookResponse: Content {

  let eventType: String
  let eventTime: Int
  let symbol: String
  let firstUpdateId: Int
  let finalUpdateId: Int
  let bids: [[Double]]
  let asks: [[Double]]
  
  enum CodingKeys: String, CodingKey {
    case eventType = "e"
    case eventTime = "E"
    case symbol = "s"
    case firstUpdateId = "U"
    case finalUpdateId = "u"
    case bids = "b"
    case asks = "a"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    eventType = try container.decode(String.self, forKey: .eventType)
    eventTime = try container.decode(Int.self, forKey: .eventTime)
    symbol = try container.decode(String.self, forKey: .symbol)
    firstUpdateId = try container.decode(Int.self, forKey: .firstUpdateId)
    finalUpdateId = try container.decode(Int.self, forKey: .finalUpdateId)
    bids = try container.decode([[String]].self, forKey: .bids).compactMap({$0.compactMap({Double($0)})})
    asks = try container.decode([[String]].self, forKey: .asks).compactMap({$0.compactMap({Double($0)})})
  }
}
