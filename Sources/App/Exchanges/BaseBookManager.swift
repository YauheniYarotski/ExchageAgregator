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
  let intervalUpdateFullBookViaRest: Double = 10
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
          self.startGetingRestBooks()
          
        }
      }
    } else {
      self.cooverForWsStartListenBooks()
      self.startGetingRestBooks()
    }
    
  }
  
  private func startGetingRestBooks() {
    Jobs.add(interval: .seconds(intervalUpdateFullBookViaRest), action: {
        self.cooverForGetFullBook()
    })
  }
  
  func removeOrders(fromMindBid: Double, toMaxAsk: Double, pair: Pair) {
    serialQueue.async {
      var book = self.books[pair] == nil ? [:] : self.books[pair]!
      
      for priceLeve in book {
        if priceLeve.key > 0 && priceLeve.key > fromMindBid {
          book[priceLeve.key] = nil
        } else if priceLeve.key < 0 && -priceLeve.key < toMaxAsk {
          book[priceLeve.key] = nil
        }
      }
      self.books[pair] = book
    }
  }
  
  
  func updateBook(book:[Double:Double], pair: Pair, reloadFullBook: Bool = false) {
    serialQueue.async {
      if reloadFullBook {
        self.books[pair] = book
      } else {
        var bookCopy = self.books[pair] == nil ? [:] : self.books[pair]!
        book.forEach({ (priceLevel) in
          bookCopy[priceLevel.key] = priceLevel.value > 0 ? priceLevel.value : nil
        })
        self.books[pair] = bookCopy
      }
    }
  }
  
  func updateBook(asks: [[Double]], bids: [[Double]], pair: Pair, reloadFullBook: Bool = false) {
    serialQueue.async {
      
      var book = reloadFullBook || self.books[pair] == nil ? [:] : self.books[pair]!
      bids.forEach { (bid) in
        let price = bid[0]
        let amount = bid[1]
        if amount > 0 {
          book[price] = amount
        } else {
          book[price] = nil
        }
      }
      
      asks.forEach { (ask) in
        let price = -ask[0]
        let amount = ask[1]
        if amount > 0 {
          book[price] = amount
        } else {
          book[price] = nil
        }
      }
      self.books[pair] = book
    }
    
  }
  
  func getPairsAndCoins() {}
  func cooverForWsStartListenBooks() {}
  func stopListenTickers() {}
  func cooverForGetFullBook() {}
  
}
