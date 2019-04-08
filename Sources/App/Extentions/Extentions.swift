//
//  Extentions.swift
//  App
//
//  Created by Yauheni Yarotski on 4/8/19.
//

import Foundation


extension Double {
  /// Rounds the double to decimal places value
  func rounded(toPlaces places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
  
  func granulate(toGranulation granulation:Double) -> Double {
    let rezult = (self/granulation).rounded() * granulation
//    print(self, rezult)
    return  rezult
  }
}
