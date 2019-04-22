import Vapor

struct BitstampPair {
  static let separator: String = "/"
  let firstAsset: BitstampCoin
  let secondAsset: BitstampCoin
  
  var symbol: String {
    return "\(firstAsset.rawValue+PoloniexPair.separator)\(secondAsset.rawValue)"
  }
  var urlSymbol: String {
    return "\(firstAsset.rawValue)\(secondAsset.rawValue)".lowercased()
  }
  init(firstAsset: BitstampCoin, secondAsset: BitstampCoin) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
  init?(string: String) {
    let parts = string.uppercased().components(separatedBy: BitstampPair.separator)
    if parts.count == 2,
      let first = BitstampCoin(rawValue: parts[0]),
      let second = BitstampCoin(rawValue: parts[1]) {
      firstAsset = first
      secondAsset = second
    } else {
      return nil
    }
  }
  
  init?(urlString: String) {
    let urlString = urlString.uppercased()
    for coin1 in BitstampCoin.allCases where urlString.hasPrefix(coin1.rawValue) {
      let suffix = urlString.replacingOccurrences(of: coin1.rawValue, with: "")
      for coin2 in BitstampCoin.allCases where suffix == coin2.rawValue {
          firstAsset = coin1
          secondAsset = coin2
          return
        }
      }
    return nil
  }
  
  
}

extension BitstampPair: Hashable {
  var hashValue: Int {
    return (self.firstAsset.rawValue+self.secondAsset.rawValue).hashValue
  }
}


extension BitstampCoin: CaseIterable {}

enum BitstampCoin: String, Content {
  case bch = "BCH"
  case btc = "BTC"
  case eth = "ETH"
  case eur = "EUR"
  case ltc = "LTC"
  case usd = "USD"
  case xrp = "XRP"
}
