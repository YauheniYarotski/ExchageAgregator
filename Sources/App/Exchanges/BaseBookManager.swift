//
//  BaseTikerManager.swift
//  App
//
//  Created by Yauheni Yarotski on 4/15/19.
//

import Foundation
import Vapor
import Jobs

class BaseBookManager<Pair:Hashable, Coin: Hashable> {
  
  static var typeName: String {
    return String(describing: self)
  }
  
  let serialQueue = DispatchQueue.init( label: "queue \(typeName)")
  
  
  var pairs: Set<Pair>? {
    didSet {
      if let pairs = pairs {
        didGetPairs?(pairs)
      }
    }
  }
  var didGetPairs: ((_ pairs: Set<Pair>)->())?
  
  var coins: Set<Coin>?
  
  private var books: [Pair:[Double:Double]] = [:] {
    didSet {
      booksDidUpdate?(books)
    }
  }
  var booksDidUpdate: ((_ books: [Pair:[Double:Double]])->())?
  
  final func startListenBooks() {
    weak var job: Job?
    if self.pairs == nil || self.coins == nil {
      job = Jobs.delay(by: .seconds(2), interval: .seconds(7)) {
        if self.pairs == nil || self.coins == nil {
          self.getPairsAndCoins()
        }
      }
    }
    
    if job != nil {
      Jobs.add(interval: .seconds(5)) {
        if job != nil, let _ = self.pairs, let _ = self.coins {
          job?.stop()
          self.cooverForWsStartListenBooks()
        }
      }
    } else {
      self.cooverForWsStartListenBooks()
    }
    
  }
  
  func getPairsAndCoins() {}
  func cooverForWsStartListenBooks() {}
  func stopListenTickers() {}
  
  
  
  
  func removeOrders(fromMindBid: Double, toMaxAsk: Double, pair: Pair) {
    serialQueue.async {
      let pairBook = self.books[pair] ?? [:]
      for priceLeve in pairBook {
        if priceLeve.key > 0 && priceLeve.key > fromMindBid {
          self.books[pair]?[priceLeve.key] = nil
        } else if priceLeve.key < 0 && -priceLeve.key < toMaxAsk {
          self.books[pair]?[priceLeve.key] = nil
        }
      }
    }
  }
  
  
  func updateBook(book:[Double:Double], pair: Pair) {
    serialQueue.async {
      var pairBook = self.books[pair] ?? [:]
      for priceLevel in book {
        let price = priceLevel.key
        let amount = priceLevel.value
        if amount > 0 {
          pairBook[price] = amount
        } else {
          pairBook[price] = nil
        }
      }
      self.books[pair] = pairBook
    }
  }
  
  
}



//struct Book: Content {
//  let tradeTime: Int
//  let pair: CoinPair
//  let prices: [Double:Double]
//}
