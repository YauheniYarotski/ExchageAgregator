//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs
import Vapor

class BinanceManager: BaseBookManager<BinancePair, BinanceCoin> {
  
  let ws = BinanceWs()
  
  override init() {
    super.init()
    ws.responseHandler = {  response in
      guard let binancePair = BinancePair(string: response.symbol) else {return}
      var book = [Double:Double]()
      response.asks.forEach({ (level) in
        book[-level[0]] = level[1]
      })
      response.bids.forEach({ (level) in
        book[level[0]] = level[1]
      })
      self.updateBook(book: book, pair: binancePair)
    }
    
  }
  
  override func getPairsAndCoins() {
    let infoRequest = RestRequest.init(hostName: "api.binance.com", path: "/api/v1/exchangeInfo")
    var pairs = Set<BinancePair>()
    var coins = Set<BinanceCoin>()
    GenericRest.sendRequest(request: infoRequest, completion: { (response: BinanceInfoResponse) in
      for symbolReponse in response.symbols {
        if let pair = BinancePair(string: symbolReponse.symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all binance asstets updated:",symbolReponse.symbol)
        }
      }
      
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
      
    }, errorHandler:  {  error in
      print("Gor error for request: \(infoRequest)",error)
    })
  }
  
  override func cooverForWsStartListenBooks() {
    super.cooverForWsStartListenBooks()
    ws.startListenBooks()
  }
  
  override func cooverForGetFullBook() {
    self.getFullBook()
  }
  
  func getFullBook() {
    let pair = BinancePair(firstAsset: .btc, secondAsset: .usdt)
    let request = RestRequest.init(hostName: "api.binance.com", path: "/api/v1/depth", queryParameters: ["limit":"1000","symbol":pair.symbol])
    
    GenericRest.sendRequest(request: request, completion: { (response: BinanceBookRestResponse) in
      //1) rest gets only 1000 prices, but in book more, so, reload only from min to max
      if  let minBid = response.minBid, minBid.count == 2, let maxAsk = response.maxAsk, maxAsk.count == 2 {
        let minBidPrice = minBid[0]
        let maxAskPrice = maxAsk[0]
        self.removeOrders(fromMindBid: minBidPrice, toMaxAsk: maxAskPrice, pair: pair)
      }
      var book = [Double:Double]()
      response.asks.forEach({ (level) in
        book[-level[0]] = level[1]
      })
      response.bids.forEach({ (level) in
        book[level[0]] = level[1]
      })
      self.updateBook(book: book, pair: pair)
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
    
  }
  
  
}


struct BinanceInfoResponse: Content {
  let timezone: String
  let serverTime: UInt
  let symbols: [BinanceSymbolResponse]
}

struct BinanceSymbolResponse: Content  {
  let symbol: String
  let status: String
  let baseAsset: String
  let quoteAsset: String
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
