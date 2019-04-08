//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket

class CoinbaseProWs: Startable {
  
  var bookResponse: ((_ bookResponse: BitstampBookResponse)->())?
  
  func start() {
    
    guard let ws = try? HTTPClient.webSocket(scheme: .wss, hostname: "ws-feed.pro.coinbase.com", on: wsClientWorker).wait() else {
      print("CoinbaseProWS is nil")
      return
    }

//    let bookRequest: [String : Any] = ["type": "subscribe", "product_ids": ["ETH-USD", "ETH-EUR"], "channels": ["level2", "heartbeat"]]
//    guard let bookRequestJsonData = try?  JSONSerialization.data(
//      withJSONObject: bookRequest,
//      options: []
//      ) else {
//        print("can't parse bitfin json")
//        return
//    }
//    let request = CoinbaseProInfoResponse(type: "\subscribe", channels: [CoinbaseProChanel(name: "\heartbeat", product_ids: ["\ETH-EUR"])])
//    let str = "{\"type\":\"subscribe\",\"product_ids\":[\"ETH-USD\"],\"channels\": [\"level2\"]}"
//    let encodedData = try! JSONEncoder().encode(request)
//    ws.send(str)
//    print(str)
    
//    print(String(bytes: data, encoding: .utf8)!)
    
//    ws.send(encodedData)
    
    
    ws.onError { (ws, error) in
      print(error)
    }
    
    ws.onText { ws, text in
                  print(text)
      guard  let jsonData = text.data(using: .utf8) else {
        print("Error with parsing coinbasepro ws response")
        return
      }
//      if let bookResponse: BitstampBookResponse = try? JSONDecoder().decode(BitstampBookResponse.self, from: jsonData) {
//        self.bookResponse?(bookResponse)
//      } else if let _: BitstampInfoResponse = try? JSONDecoder().decode(BitstampInfoResponse.self, from: jsonData)  {
//        //do nothing for now
//      }
//      else {
//        print("Error with parsing bitstamp ws response")
//        return
//      }
      
    }
    
  }
  
}



// // Response
//{
//  "type": "subscriptions",
//  "channels": [
//  {
//  "name": "level2",
//  "product_ids": [
//  "ETH-USD",
//  "ETH-EUR"
//  ],
//  },
//  {
//  "name": "heartbeat",
//  "product_ids": [
//  "ETH-USD",
//  "ETH-EUR"
//  ],
//  },
//  {
//  "name": "ticker",
//  "product_ids": [
//  "ETH-USD",
//  "ETH-EUR",
//  "ETH-BTC"
//  ]
//  }
//  ]
//}
//    {
//      "type": "subscribe",
//      "product_ids": [
//      "ETH-USD",
//      "ETH-EUR"
//      ],
//      "channels": [
//      "level2",
//      "heartbeat",
//      {
//      "name": "ticker",
//      "product_ids": [
//      "ETH-BTC",
//      "ETH-USD"
//      ]
//      }
//      ]
//    }

//{
//"type": "subscribe",
//"channels": [{ "name": "heartbeat", "product_ids": ["ETH-EUR"] }]
//}



struct CoinbaseProBookRequest: Content {
  let type: String
  let product_ids: [String]
  let channels: [String]
}

struct CoinbaseProInfoResponse: Content {
  let type: String
  let channels: [CoinbaseProChanel]
}

struct CoinbaseProChanel: Content {
  let name: String
  let product_ids: [String]
}


//struct BitstampBookResponse: Content {
//
//  let event: String
//  let channel: String
//  let data: BitstampBookData
//
//  var symbol: String {
//    return channel.replacingOccurrences(of: "diff_order_book_", with: "")
//  }
//}
//
//struct BitstampBookData: Content {
//
//  let timestamp: String
//  let microtimestamp: String
//  let bids: [[Double]]
//  let asks: [[Double]]
//
//  init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: CodingKeys.self)
//
//    timestamp = try container.decode(String.self, forKey: .timestamp)
//    microtimestamp = try container.decode(String.self, forKey: .microtimestamp)
//    bids = try container.decode([[String]].self, forKey: .bids).compactMap({$0.compactMap({Double($0)})})
//    asks = try container.decode([[String]].self, forKey: .asks).compactMap({$0.compactMap({Double($0)})})
//  }
//
//}
