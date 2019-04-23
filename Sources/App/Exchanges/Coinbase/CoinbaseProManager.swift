//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Vapor
import Jobs

class CoinbaseProManager: BaseBookManager<CoinbasePair, CoinbaseCoin> {
  
  let ws = CoinbaseProWs()
  
  override init() {
    super.init()
    
    ws.bookSnapshotResponse = {  response in
      guard let pair = CoinbasePair(string: response.product_id) else {return}
      self.updateBook(asks: response.asks, bids: response.bids, pair: pair)
    }
    
    ws.bookChangesResponse = {  response in
      guard let pair = CoinbasePair(string: response.product_id) else {return}
      var prices = [Double:Double]()
      for change in response.changes {
        guard change.count == 3, let price = Double(change[1]), let amount = Double(change[2]) else {
          print("unkonw book change from coinbase2:", change)
          continue
        }
        let changeType = change[0]
        if changeType == "buy" {
          prices[price] = amount
        } else if changeType == "sell" {
          prices[-price] = amount
        } else {
          print("unkonw book change from coinbase:", change)
        }
      }
      self.updateBook(book: prices, pair: pair)
    }
    
  }
  
  override func getPairsAndCoins() {
    let request = RestRequest.init(hostName: "api.pro.coinbase.com", path: "/products/")
    GenericRest.sendRequestToGetArray(request: request, completion: { (response) in
      var pairs = Set<CoinbasePair>()
      var coins = Set<CoinbaseCoin>()
      for draftArrayPair in response {
        if let dictPair = draftArrayPair as? [String: Any],
          let symbol = dictPair["id"] as? String,
          let pair = CoinbasePair(string: symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all conbase asstets updated:",draftArrayPair)
        }
      }
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
  override func cooverForWsStartListenBooks() {
    super.cooverForWsStartListenBooks()
    ws.startListenBooks()
  }
  
  override func cooverForGetFullBook() {
    let pair = CoinbasePair(firstAsset: .btc, secondAsset: .usd)
    let request = RestRequest.init(hostName: "api.pro.coinbase.com", path: "/products/\(pair.symbol)/book", queryParameters: ["level":"3"])
    GenericRest.sendRequest(request: request, completion: { (response: CoinbaseBookRestResponse) in
      
      self.updateBook(book: response.book, pair: pair, reloadFullBook: true)
      
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }
  
}

struct CoinbaseBookRestResponse: Content {
  let sequence: Int
  let book: [Double:Double]
  
  enum CodingKeys: String, CodingKey {
    case sequence
    case bids
    case asks
  }
  
  func encode(to encoder: Encoder) throws {
  }
  
  //TODO:optimize
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    sequence = try container.decode(Int.self, forKey: .sequence)
    let bids = try container.decode([[String]].self, forKey: .bids)
    let asks = try container.decode([[String]].self, forKey: .asks)
    var book = [Double:Double]()
    bids.forEach { (bid) in
      if bid.count == 3, let price = Double(bid[0]), let amount = Double(bid[1]) {
        book[price] = (book[price] ?? 0) + amount
      }
    }
    
    asks.forEach { (ask) in
      if ask.count == 3, let price = Double(ask[0]), let amount = Double(ask[1]) {
        book[-price] = (book[-price] ?? 0) + amount
      }
    }
    self.book = book
  }
}
