import Vapor

struct BitfinexPair: Content {
  static let separator: String = ""
  let firstAsset: BitfinexCoin
  let secondAsset: BitfinexCoin
  
  var symbol: String {
    return "\(firstAsset.symbol+BitfinexPair.separator)\(secondAsset.symbol)"
  }
  
  init(firstAsset: BitfinexCoin, secondAsset: BitfinexCoin) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
  init?(string: String) {
    if string.count == 6, let firstAsset = BitfinexCoin(symbol: string.prefix(3).uppercased()), let secondAsset = BitfinexCoin(symbol: string.suffix(3).uppercased()) {
      self.firstAsset = firstAsset
      self.secondAsset = secondAsset
    } else { return nil }
  }
  
}

extension BitfinexPair: Hashable {
  var hashValue: Int {
    return (self.firstAsset.symbol+self.secondAsset.symbol).hashValue
  }
}


struct BitfinexCoin: Hashable, Content {
  let symbol: String
  
  init?(symbol: String) {
    if symbol.count == 3 {
      self.symbol = symbol.uppercased()
    } else {
      return nil
    }
  }
  
  var hashValue: Int { return symbol.hashValue }
}

