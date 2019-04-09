//
//  BinanceWs.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation
import Vapor
import WebSocket

class BitstampWs: Startable {
  
  var bookResponse: ((_ bookResponse: BitstampBookResponse)->())?
  
  func start() {
        
    guard let ws = try? HTTPClient.webSocket(scheme: .wss, hostname: "ws.bitstamp.net", on: wsClientWorker).wait() else {
      print("BinanceWS is nil")
      return
    }
    // { "event": "bts:subscribe", "data": {  "channel": "diff_order_book_btcusd"  } }
    let bookRequest: [String : Any] = ["event":"bts:subscribe", "data":["channel": "diff_order_book_btcusd"]]
    guard let bookRequestJsonData = try?  JSONSerialization.data(
      withJSONObject: bookRequest,
      options: []
      ) else {
        print("can't parse bitfin json")
        return
    }
    
    ws.send(bookRequestJsonData)
    
    ws.onText { ws, text in
      //            print(text)
      guard  let jsonData = text.data(using: .utf8) else {
        print("Error with parsing bitstamp ws response")
        return
      }
      if let bookResponse: BitstampBookResponse = try? JSONDecoder().decode(BitstampBookResponse.self, from: jsonData) {
        self.bookResponse?(bookResponse)
      } else if let _: BitstampInfoResponse = try? JSONDecoder().decode(BitstampInfoResponse.self, from: jsonData)  {
        //do nothing for now
      }
      else {
        print("Error with parsing bitstamp ws response")
        return
      }
      
    }
    
  }
  
}



//{"event":"bts:subscription_succeeded","channel":"diff_order_book_btcusd","data":{}}

//{"data": {"timestamp": "1554713158", "microtimestamp": "1554713158302715", "bids": [["5232.69", "0.10000000"], ["5232.68", "0.00000000"], ["5232.48", "1.00000000"], ["5232.47", "2.00000000"], ["5231.22", "1.00000000"], ["5230.10", "0.00000000"], ["5225.92", "0.00000000"], ["5224.20", "0.40000000"], ["5224.13", "0.04464000"], ["5223.60", "0.00000000"], ["5215.82", "0.00000000"], ["5214.85", "25.00000000"], ["5212.34", "0.00000000"], ["5212.33", "0.00895000"], ["5208.00", "0.00000000"], ["5190.00", "0.79923142"]], "asks": [["5235.78", "2.17584824"], ["5238.86", "0.00000000"], ["5241.58", "0.00000000"], ["5241.72", "1.50000000"], ["5242.24", "1.00000000"], ["5242.67", "2.86170000"], ["5245.23", "0.01513000"], ["5246.17", "2.50000000"], ["5248.51", "3.34400000"], ["5256.00", "1.10264365"], ["5257.41", "25.00000000"], ["5258.74", "0.00000000"], ["5262.40", "0.86000000"], ["5265.65", "0.00303000"], ["5272.80", "0.06000000"]]}, "event": "data", "channel": "diff_order_book_btcusd"}


//let product: Product = try! JSONDecoder().decode(Product.self, for: data)

struct BitstampInfoResponse: Content {
  let event: String
  let channel: String
}

struct BitstampBookResponse: Content {
  
  let event: String
  let channel: String
  let data: BitstampBookData
  
  var symbol: String {
    return channel.replacingOccurrences(of: "diff_order_book_", with: "")
  }
}

struct BitstampBookData: Content {
  
  let timestamp: String
  let microtimestamp: String?
  let bids: [[Double]]
  let asks: [[Double]]
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    timestamp = try container.decode(String.self, forKey: .timestamp)
    microtimestamp = try? container.decode(String.self, forKey: .microtimestamp)
    bids = try container.decode([[String]].self, forKey: .bids).compactMap({$0.compactMap({Double($0)})})
    asks = try container.decode([[String]].self, forKey: .asks).compactMap({$0.compactMap({Double($0)})})
  }
  
}
