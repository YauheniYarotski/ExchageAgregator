import FluentSQLite
import Vapor

struct CoinPair: Content, Hashable {
  static let separator = "-"
  let firstAsset: String
  let secondAsset: String
  
  var symbol: String {
    return "\(firstAsset+CoinPair.separator)\(secondAsset)"
  }
  
  enum CodingKeys: String, CodingKey {
    case firstAsset
    case secondAsset
    case symbol
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(symbol, forKey: .symbol)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    firstAsset = try container.decode(String.self, forKey: .firstAsset)
    secondAsset = try container.decode(String.self, forKey: .secondAsset)
  }
  
  init(firstAsset: String, secondAsset: String) {
    self.firstAsset = firstAsset
    self.secondAsset = secondAsset
  }
  
  init?(string: String) {
    let string = string.uppercased()
    let parts = string.components(separatedBy: CoinPair.separator)
    if parts.count == 2 {
      firstAsset = parts[0]
      secondAsset = parts[1]
    } else {
      return nil
    }
  }
  
}
