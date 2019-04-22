import Vapor

struct ExchangesBooks: Content {
  let exchangeName: ExchangeName
  let books: [BookForPair]
}

struct BookForPair: Content {
  let pair: CoinPair
  let asks: [[Double]]
  let bids: [[Double]]
  
  let totalAsks: Double
  let totalBids: Double
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(pair.symbol, forKey: .pair)
    try container.encode(asks, forKey: .asks)
    try container.encode(bids, forKey: .bids)
    try container.encode(totalAsks, forKey: .totalAsks)
    try container.encode(totalBids, forKey: .totalBids)
  }
}
