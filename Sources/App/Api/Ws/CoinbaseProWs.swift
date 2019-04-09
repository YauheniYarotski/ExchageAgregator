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
  
  public enum ProductId: String, CaseIterable {
    case BTCUSD = "BTC-USD"
    case BTCEUR = "BTC-EUR"
    case BTCGBP = "BTC-GBP"
    case ETHUSD = "ETH-USD"
    case ETHBTC = "ETH-BTC"
    case ETHEUR = "ETH-EUR"
    case ETHGBP = "ETH-GBP"
    case LTCUSD = "LTC-USD"
    case LTCBTC = "LTC-BTC"
    case LTCEUR = "LTC-EUR"
    case LTCGBP = "LTC-GBP"
    case BCHUSD = "BCH-USD"
    case BCHBTC = "BCH-BTC"
    case BCHEUR = "BCH-EUR"
    case BCHGBP = "BCH-GBP"
    case ETCUSD = "ETC-USD"
    case ETCBTC = "ETC-BTC"
    case ETCEUR = "ETC-EUR"
    case ETCGBP = "ETC-GBP"
    case ZRXUSD = "ZRX-USD"
    case ZRXBTC = "ZRX-BTC"
    case ZRXEUR = "ZRX-EUR"
    case BTCUSDC = "BTC-USDC"
    case ETHUSDC = "ETH-USDC"
    case BATUSDC = "BAT-USDC"
    case ZECUSDC = "ZEC-USDC"
  }
  
  public enum Channel: String {
    case heartbeat, ticker, level2, user, matches, full
  }
  
  public enum MessageType: String, CaseIterable {
    case error = "error"
    case subscribe = "subscribe"
    case unsubscribe = "unsubscribe"
    case subscriptions = "subscriptions"
    case heartbeat = "heartbeat"
    case ticker = "ticker"
    case snapshot = "snapshot"
    case update = "12update"
    case received = "received"
    case open = "open"
    case done = "done"
    case match = "match"
    case change = "change"
    case marginProfileUpdate = "margin_profile_update"
    case activate = "activate"
    case unknown = ""
  }
  
  
  var bookSnapshotResponse: ((_ bookSnapshotResponse: CoinbaseProBookSnapshot)->())?
  var bookChangesResponse: ((_ bookChangesResponse: CoinbaseProBookChanges)->())?
  var infoResponse: ((_ coinbaseProInfoResponse: CoinbaseProInfoResponse)->())?
  
  func start() {
    
    let request = CoinbaseProRequest(type: MessageType.subscribe.rawValue, channels:  [Channel.level2.rawValue], product_ids: [ProductId.BTCUSD.rawValue])
    
    guard let encodedData = try? JSONEncoder().encode(request), let jsonString = String(bytes: encodedData, encoding: .utf8), let ws = try? HTTPClient.webSocket(scheme: .wss, hostname: "ws-feed.pro.coinbase.com", maxFrameSize: 1 << 19, on: wsClientWorker).wait()
      else {
        print("CoinbaseProWS is nil")
        return
    }
    
    ws.send(jsonString)
    
    ws.onError { (ws, error) in
      print("error from ws coinbasePro",error)
    }
    
    ws.onCloseCode { (code) in
      print("closing ws coinbasePro")
    }
    
    ws.onText { ws, text in
      //            print(text)
      guard  let jsonData = text.data(using: .utf8) else {
        print("Error with parsing coinbasepro ws response")
        return
      }
      if let coinbaseProBookChanges = try? JSONDecoder().decode(CoinbaseProBookChanges.self, from: jsonData) {
        self.bookChangesResponse?(coinbaseProBookChanges)
      } else if let coinbaseProBookSnapshot = try? JSONDecoder().decode(CoinbaseProBookSnapshot.self, from: jsonData)  {
        self.bookSnapshotResponse?(coinbaseProBookSnapshot)
      } else if let coinbaseProInfoResponse = try? JSONDecoder().decode(CoinbaseProInfoResponse.self, from: jsonData)  {
        self.infoResponse?(coinbaseProInfoResponse)
      } else {
        print("Error with parsing coinbase ws response:", text)
        return
      }
      
    }
    
    
  }
  
}



// 1 first responce
//{"product_id":"BTC-USD","type":"snapshot","bids":[["5152.48","0.001"],["5152.47","0.00162834"],["5151.19","0.0957"],["5150.59","2.5"],["5150.33","0.5"],["5150.15","2"],["5150.04","1"],["5150","6.21230792"],["5149.44","0.1"],["5149.06","0.15"],["5149.03","0.5"],["5149","2"],["5148.75","0.20414157"],["5148.66","3"],["5148.65","1"],["5148.59","0.0197"],["5148.57","0.001"],["5148.33","0.003"],["5148.12","0.00224548"],["5148","0.16711387"],["5147.99","2"],["5147.78","5"],["5147.39","0.2036"],["5147.1","4.851"],["5147.08","7.58"],["5147.04","1"],["5146.73","0.02543836"],["5146.62","0.5"],["5146.56","0.001"],["5146.19","0.0196"],["5146","0.1220622"],["5145.31","1.111"],["5145.28","6"],["5145.06","0.61184061"],["5145","5.65193481"],["5144.5","1.11"],["5144.49","1.9392"],["5144.44","0.125"],["5144.39","0.001"],["5144.36","0.0141776"],["5144.25","0.001"],["5144.14","5"],["5144.09","0.38879"],["5144.03","0.15503875"],["5144","0.37"],["5143.95","1.65641117"],["5143.94","6.3"],["5143.84","0.01944147"],["5143.78","0.0197"],["5143.62","0.03403631"],["5143.46","0.62090303"],["5143.12", ... "asks": ...

// 2 {"type":"l2update","product_id":"BTC-USD","time":"2019-04-09T10:19:51.690Z","changes":[["buy","5134.96000000","0.64980084"]]}

// 3 resp: {"type":"subscriptions","channels":[{"name":"level2","product_ids":["BTC-USD"]}]}

struct CoinbaseProRequest: Content {
  let type: String
  let channels: [String]
  let product_ids: [String]
}

struct CoinbaseProInfoResponse: Content {
  let type: String
  let channels: [CoinbaseProChannel]
}

struct CoinbaseProChannel: Content {
  let name: String
  let product_ids: [String]
}

struct CoinbaseProBookSnapshot: Content {
  let type: String
  let product_id: String
  let bids: [[Double]]
  let asks: [[Double]]
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(String.self, forKey: .type)
    product_id = try container.decode(String.self, forKey: .product_id)
    bids = try container.decode([[String]].self, forKey: .bids).compactMap({$0.compactMap({Double($0)})})
    asks = try container.decode([[String]].self, forKey: .asks).compactMap({$0.compactMap({Double($0)})})
  }
}

struct CoinbaseProBookChanges: Content {
  let type: String
  let product_id: String
  let time: String
  let changes: [[String]]
}

