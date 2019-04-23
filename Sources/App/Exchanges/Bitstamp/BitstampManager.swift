//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs


class BitstampManager: BaseBookManager<BitstampPair,BitstampCoin> {
  
  let restApi = BitstampRest()
  let ws = BitstampWs()
  
  override init() {
    super.init()
    
    ws.didGetBooks = {  response in
      guard let pair = BitstampPair(urlString: response.symbol) else {return}
      self.updateBook(asks: response.data.asks, bids: response.data.bids, pair: pair)
    }
    
    restApi.didGetFullBook = { book, pair in
      self.updateBook(asks: book.asks, bids: book.bids, pair: pair, reloadFullBook: true)
    }
  }
  
  override func cooverForWsStartListenBooks() {
    ws.startListenBooks()
  }
  
  override func cooverForGetFullBook() {
    self.restApi.getFullBook(for: BitstampPair(firstAsset: .btc, secondAsset: .usd))
  }
  
  override func getPairsAndCoins() {
    let request = RestRequest.init(hostName: "www.bitstamp.net", path: "/api/v2/trading-pairs-info/")
    
    GenericRest.sendRequestToGetArray(request: request, completion: { (response) in
      var pairs = Set<BitstampPair>()
      var coins = Set<BitstampCoin>()
      for draftArrayPair in response {
        if let dictPair = draftArrayPair as? [String: Any],
          let symbol = dictPair["name"] as? String,
          let pair = BitstampPair(string: symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all bitstamp asstets updated:",draftArrayPair)
        }
      }
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
    }, errorHandler:  {  error in
      print("Gor error for request: \(request)",error)
    })
  }

  
}

