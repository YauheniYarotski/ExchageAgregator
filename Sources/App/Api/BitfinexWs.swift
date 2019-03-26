//
//  BitfinexWs.swift
//  App
///Users/yauheniyarotski/Downloads/data.json
//  Created by Yauheni Yarotski on 6/14/18.
//


import Vapor
import WebSocket
import ObjectMapper

class BitfinexWs {
  
  var echoResponse: ((_ echoReponse: BitfinexBookResponse)->())?
  var fullBookResponse: ((_ fullPricesSnapshotResponse: BitfinexBookAllPricesSnapshotResponse)->())?
  var onePriceBookResponse: ((_ onePriceSnapshotResponse: BitfinexBookOnePriceSnapshotResponse)->())?
  var commandBookResponse: ((_ commnad: BitfinexBookCommand)->())?
  
  func start() {
    
    let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    
    guard let ws = try? HTTPClient.webSocket(scheme: .wss, hostname: "api.bitfinex.com", path: "/ws/2", on: worker).wait() else {
      print("BitfinWS is nil")
      return
    }
    
    let bookRequest: [String : Any] = ["event":"subscribe", "channel":"book", "symbol":"tBTCUSD", "prec":"P0"]
    guard let bookRequestJsonData = try?  JSONSerialization.data(
      withJSONObject: bookRequest,
      options: []
      ) else {
        print("can't parse bitfin json")
        return
    }
    
    ws.send(bookRequestJsonData)
    
    
    ws.onText { ws, text in
      //print(text)
      
      if let parsedArrayWithAny = Mapper<BitfinexBookResponse>.parseJSONString(JSONString: text) as? [Any],
        parsedArrayWithAny.count == 2, let chanId = parsedArrayWithAny[0] as? Int {
        
        if let draftPriceSnap = parsedArrayWithAny[1] as? [Double] {
          let priceSnap = BitfinexBookPriceSnapshot(price: draftPriceSnap[0], count: Int(draftPriceSnap[1]), amount: draftPriceSnap[2])
          let priceSnapshotResponse = BitfinexBookOnePriceSnapshotResponse(chanId: chanId, priceSnapshot: priceSnap)
          self.onePriceBookResponse?(priceSnapshotResponse)
//          print(text)
          
        } else if let draftPricesSnap = parsedArrayWithAny[1] as? [[Double]] {
          var pricesSnapshor = [BitfinexBookPriceSnapshot]()
          for draftPriceSnap in draftPricesSnap {
            let priceSnap = BitfinexBookPriceSnapshot(price: draftPriceSnap[0], count: Int(draftPriceSnap[1]), amount: draftPriceSnap[2])
            pricesSnapshor.append(priceSnap)
            
          }
          let priceSnapshotResponse = BitfinexBookAllPricesSnapshotResponse(chanId: chanId, prices: pricesSnapshor)
          self.fullBookResponse?(priceSnapshotResponse)
          
        } else if let commandString =  parsedArrayWithAny[1] as? String {
          let command = BitfinexBookCommand(chanId: chanId, command: commandString)
          self.commandBookResponse?(command)
        } else {
          print("annown answer from server", text)
        }
        
      } else if let bitfinexBookResponse = Mapper<BitfinexBookResponse>().map(JSONString: text) {
        
        self.echoResponse?(bitfinexBookResponse)
        
      } else {
        print("annown answer from server", text)
      }
    }
    
  }
  
}


struct BitfinexBookResponse: Mappable {
  var event: String = ""
  var channel: String = ""
  var chanId: Int = 0
  var symbol: String = ""
  var prec: String = ""
  var freq: String = ""
  var len: String = ""
  var pair: String = ""
  
  init?(map: Map) {
    guard let _ = map.JSON["event"],let _ = map.JSON["channel"],let _ = map.JSON["chanId"]
      else {
        return nil
    }
  }
  
  mutating func mapping(map: Map) {
    event             <- map["event"]
    channel             <- map["channel"]
    chanId                <- map["chanId"]
    symbol               <- map["symbol"]
    prec               <- map["prec"]
    freq                  <- map["freq"]
    len                  <- map["len"]
    pair                  <- map["pair"]
  }
}


struct BitfinexBookAllPricesSnapshotResponse {
  var chanId: Int = 0
  var prices: [BitfinexBookPriceSnapshot] = []
  
}

struct BitfinexBookOnePriceSnapshotResponse {
  var chanId: Int = 0
  var priceSnapshot: BitfinexBookPriceSnapshot = BitfinexBookPriceSnapshot(price: 0, count: 0, amount: 0)
}

struct BitfinexBookPriceSnapshot {
  var price: Double = 0.0
  var count: Int = 0
  var amount: Double = 0.0
}

struct BitfinexBookCommand {
  var chanId: Int = 0
  var command: String = ""
}



//1fst answer is  {"event":"subscribed","channel":"book","chanId":1,"symbol":"tBTCUSD","prec":"P0","freq":"F0","len":"25","pair":"BTCUSD"}
//2nd is  [1,[[4034.7,4,3.12815054],[4034.6,2,1.51148129],[4034.5,2,0.27122955],[4034.3,1,0.13207276],[4033.8,1,1],[4032.7,1,0.6334],[4032.6,4,5.21677933],[4032.5,1,10.999],[4032.4,3,2.642666],[4032,1,1.75],[4031.9,1,0.11],[4031.8,2,1.56788157],[4031.4,1,1.18016659],[4031,1,0.178277],[4030.9,1,0.04829812],[4030.8,1,3.57249181],[4030.6,1,1.239236],[4030.5,1,8.999],[4030.2,1,0.006],[4030,1,0.03702787],[4029.4,2,0.97106094],[4029.3,1,0.61062618],[4029.2,1,3.73010482],[4029.1,1,0.84844591],[4029,1,1.41],[4034.8,6,-10.90582987],[4034.9,1,-0.675],[4035,2,-97.61577363],[4035.1,1,-8.999],[4035.2,1,-3.56859635],[4035.9,1,-1.23923601],[4036.3,1,-0.11],[4036.5,1,-1.75],[4036.7,1,-0.11],[4036.9,2,-0.93710235],[4037,2,-1.42753082],[4037.4,1,-0.61572141],[4037.5,1,-4.12053599],[4037.6,1,-0.5446878],[4037.7,1,-1],[4037.9,1,-10.999],[4038,1,-3.46],[4038.2,2,-1.09],[4038.9,1,-0.93222299],[4039.2,1,-0.00541316],[4039.8,1,-0.59998225],[4039.9,1,-1.04833391],[4040,1,-0.03702843],[4040.7,1,-0.5],[4040.8,1,-0.6]]]
//3d is  [1,[4039.2,0,-1]]
