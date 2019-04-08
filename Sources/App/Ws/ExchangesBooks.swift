import Vapor

struct ExchangesBooks: Content {
  let exchangeName: String
  let books: [BookForPair]
}

struct BookForPair: Content {
  let pair: String
  let asks: [[Double]]
  let bids: [[Double]]
  
  let totalAsks: Double
  let totalBids: Double
}
