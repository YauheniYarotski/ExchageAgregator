//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class CoinbaseProManager: BaseExchangeManager {
  
  override init() {
    super.init()
    let ws = CoinbaseProWs()
    ws.bookSnapshotResponse = {  response in
      self.updateBook(asks: response.asks, bids: response.bids, pair: response.product_id)
    }
    
    ws.bookChangesResponse = {  response in
      var asks = [[Double]]()
      var bids = [[Double]]()
      for change in response.changes {
        guard change.count == 3, let price = Double(change[1]), let amount = Double(change[2]) else {
          print("unkonw book change from coinbase2:", change)
          continue
        }
        let changeType = change[0]
        if changeType == "buy" {
          bids.append([price,amount])
        } else if changeType == "sell" {
          asks.append([price,amount])
        } else {
          print("unkonw book change from coinbase:", change)
        }
      }
      self.updateBook(asks: asks, bids: bids, pair: response.product_id)
    }
    
    api = ws
  }
  
  
  func updateBook(asks: [[Double]], bids: [[Double]], pair: String) {
    var pairBook = book[pair] ?? [:]
    for bid in bids {
      let price = bid[0]
      let amount = bid[1]
      if amount > 0 {
        pairBook[price] = amount
      } else {
        pairBook[price] = nil
      }
    }

    for ask in asks {
      let price = -ask[0]
      let amount = ask[1]
      if amount > 0 {
        pairBook[price] = amount
      } else {
        pairBook[price] = nil
      }
    }

    book[pair] = pairBook

//    print("bids",pairBook.filter({$0.key > 0}).count)
//    print("asks",pairBook.filter({$0.key < 0}).count)
  }
  
}

