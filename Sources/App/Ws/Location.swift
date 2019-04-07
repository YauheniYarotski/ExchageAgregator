

import Vapor

//struct Location: Content {
//  let latitude: Double
//  let longitude: Double
//}

struct ExchangesBooks: Content {
  let exchangeName: String
  let books: [HalfBook]
}

struct HalfBook: Content {
  let pair: String
  let asks: [[Double]]
  let bids: [[Double]]
  
  var totalAsks: Double
//  var roundeTotalAsks: Double {
//    return totalAsks.rounded(toPlaces: 3)
//  }
  
  let totalBids: Double
}
