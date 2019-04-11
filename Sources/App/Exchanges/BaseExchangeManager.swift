//
//  BitfinexManager.swift
//  App
//
//  Created by Yauheni Yarotski on 3/26/19.
//

import Foundation


class BaseExchangeManager {
  
  var api: Startable?
  
  var book: [String:[Double:Double]] = [:] { //[pair:[Price:Amount]]
    didSet {
      bookDidUpdate?(book)
    }
  }
  var bookDidUpdate: ((_ book: [String:[Double:Double]])->())?
  
  func startCollectData() {
    api?.start()
  }
  
  func removeOrders(fromMindBid: Double, toMaxAsk: Double, pair: String) {
    let pairBook = book[pair] ?? [:]
    for priceLeve in pairBook {
      if priceLeve.key > 0 && priceLeve.key > fromMindBid {
        book[pair]?[priceLeve.key] = nil
      } else if priceLeve.key < 0 && -priceLeve.key < toMaxAsk {
        book[pair]?[priceLeve.key] = nil
      }
    }
  }
  
  
}

