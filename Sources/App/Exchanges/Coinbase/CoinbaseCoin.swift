import Vapor

struct CoinbasePair {
  static let separator: String = "-"
  let firstAsset: CoinbaseCoin
  let secondAsset: CoinbaseCoin
  
  var symbol: String {
    return "\(firstAsset.rawValue+CoinbasePair.separator)\(secondAsset.rawValue)"
  }
  init(firstAsset: CoinbaseCoin, secondAsset: CoinbaseCoin) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
  init?(string: String) {
    let parts = string.components(separatedBy: CoinbasePair.separator)
    if parts.count == 2,
      let first = CoinbaseCoin(rawValue: parts[0]),
      let second = CoinbaseCoin(rawValue: parts[1]) {
      firstAsset = first
      secondAsset = second
    } else {
      return nil
    }
  }
}
extension CoinbasePair: Hashable {
  var hashValue: Int {
    return (self.firstAsset.rawValue+self.secondAsset.rawValue).hashValue
  }
}


extension CoinbaseCoin: CaseIterable {}

enum CoinbaseCoin: String, Content {
  case bat = "BAT"
  case bch = "BCH"
  case btc = "BTC"
  case cvc = "CVC"
  case dai = "DAI"
  case dnt = "DNT"
  case eos = "EOS"
  case etc = "ETC"
  case eth = "ETH"
  case eur = "EUR"
  case gbp = "GBP"
  case gnt = "GNT"
  case loom = "LOOM"
  case ltc = "LTC"
  case mana = "MANA"
  case mkr = "MKR"
  case rep = "REP"
  case usd = "USD"
  case usdc = "USDC"
  case xlm = "XLM"
  case xrp = "XRP"
  case zec = "ZEC"
  case zrx = "ZRX"
}
