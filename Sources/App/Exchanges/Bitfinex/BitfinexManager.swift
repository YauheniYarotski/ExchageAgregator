//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation
import Jobs


class BitfinexManager: BaseBookManager<BitfinexPair,BitfinexCoin> {
  
  private let ws = BitfinexWs()
  private let restApi = BitfinexRest()
  
  private func convertPrices(price:Double, amount:Double, count: Int) -> (Double,Double) {
    let price = amount > 0 ? price : -price
    let amount = count == 0 ? 0 : abs(amount)
    return (price,amount)
  }
  
  override init() {
    super.init()
    
    ws.onePriceBookResponse = { response in
      guard let pair = BitfinexPair(string: response.pair) else {return}
      let converted = self.convertPrices(price: response.priceSnapshot.price, amount: response.priceSnapshot.amount, count: response.priceSnapshot.count)
      self.updateBook(book: [converted.0:converted.1], pair: pair)
    }
    
    ws.fullBookResponse = {  response in
      guard let pair = BitfinexPair(string: response.pair) else {return}
      var books = [Double:Double]()
      response.prices.forEach({ (prices) in
        let converted = self.convertPrices(price: prices.price, amount: prices.amount, count: prices.count)
        books[converted.0] = converted.1
      })
      self.updateBook(book: books, pair: pair)
    }
    
    
    restApi.didGetFullBook = { response in
      guard let pair = BitfinexPair(string: response.pair) else {return}
      if let minBid = response.minBid, let maxAsk = response.maxAsk {
        self.removeOrders(fromMindBid: minBid.price, toMaxAsk: maxAsk.price, pair: pair)
      }
      var books = [Double:Double]()
      for prices in response.prices {
        let converted = self.convertPrices(price: prices.price, amount: prices.amount, count: prices.count)
        books[converted.0] = converted.1
      }
      self.updateBook(book: books, pair: pair)
    }
    
    restApi.didGetPairs = { responsePairs in
      var pairs = Set<BitfinexPair>()
      var coins = Set<BitfinexCoin>()
      for symbol in responsePairs {
        if let pair = BitfinexPair(string: symbol) {
          pairs.insert(pair)
          coins.insert(pair.firstAsset)
          coins.insert(pair.secondAsset)
        } else {
          print("Waring!: not all \(self) asstets updated:",symbol)
        }
      }
      
      self.pairs = pairs.count > 5 ? pairs : nil
      self.coins = coins.count > 5 ? coins : nil
      
    }
  }
  
  internal override func cooverForWsStartListenBooks() {
    ws.startListenBooks()
    Jobs.delay(by: .seconds(9), interval: .seconds(30)) {
      self.restApi.getFullBook(for: "BTCUSD")
    }
  }
  
  internal override func getPairsAndCoins() {
    restApi.getPairs()
  }
  
  
  
  
  
}

