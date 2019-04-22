//
//  BitstampRest.swift
//  App
//
//  Created by Yauheni Yarotski on 4/9/19.
//

import Foundation
import Vapor

struct RestRequest {
  let path: String
  let queryParameters: [String: String]?
  let hostName: String
  let httpMethod: HTTPMethod
  let port: Int?
  
  init(hostName: String, path: String, queryParameters:[String: String]? = nil, httpMethod: HTTPMethod = .GET, port: Int? = nil) {
    self.hostName = hostName
    self.path = path
    self.queryParameters = queryParameters
    self.httpMethod = httpMethod
    self.port = port
  }
  
}

class GenericRest {
  
  static func sendRequest<T: Content>(request: RestRequest, completion: ((_ response: T)->())?, errorHandler:((_ error: Error)->())?) {
    
    var urlComponents = URLComponents()
    urlComponents.path = request.path
    urlComponents.queryItems = [URLQueryItem]()
    for queryParameter in request.queryParameters ?? [:] {
      let queryItem = URLQueryItem(name: queryParameter.key, value: queryParameter.value)
      urlComponents.queryItems?.append(queryItem)
    }
    
    //"api.binance.com"
    
    let httpReq = HTTPRequest(method: request.httpMethod, url: urlComponents.url!.absoluteString)
    
    let _ = HTTPClient.connect(scheme: .https, hostname: request.hostName, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ httpResponse in
        if let data = httpResponse.body.data, let response = try? JSONDecoder().decode(T.self, from: data) {
          completion?(response)
        } else {
          print("error parsing json:", request, httpResponse.body)
        }
      }).catch({ (error) in
        print("err:",error)
      })
      }.catch { (error) in
        print("err:",error)
    }
  }
  
  static func sendRequest(request: RestRequest, completion: ((_ response: [String:Any])->())?, errorHandler:((_ error: Error)->())?) {
    
    var urlComponents = URLComponents()
    urlComponents.path = request.path
    for queryParameter in request.queryParameters ?? [:] {
      urlComponents.queryItems = []
      let queryItem = URLQueryItem(name: queryParameter.key, value: queryParameter.value)
      urlComponents.queryItems?.append(queryItem)
    }
    
    //"api.binance.com"
    
    let httpReq = HTTPRequest(method: request.httpMethod, url: urlComponents.url!.absoluteString)
    
    let _ = HTTPClient.connect(scheme: .https, hostname: request.hostName, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ httpResponse in
        
        if let data = httpResponse.body.data,
          let parsedAny = try? JSONSerialization.jsonObject(with:
            data, options: []),
          let dcit = parsedAny as? [String:Any] {
          completion?(dcit)
        } else {
          print("error parsing dict json:", httpResponse.body)
        }
      }).catch({ (error) in
        print("err:",error)
      })
      }.catch { (error) in
        print("err:",error)
    }
  }
  
  
  static func sendRequestToGetArray(request: RestRequest, completion: ((_ response: [Any])->())?, errorHandler:((_ error: Error)->())?) {
    
    var urlComponents = URLComponents()
    urlComponents.path = request.path
    for queryParameter in request.queryParameters ?? [:] {
      urlComponents.queryItems = []
      let queryItem = URLQueryItem(name: queryParameter.key, value: queryParameter.value)
      urlComponents.queryItems?.append(queryItem)
    }
    
    //"api.binance.com"
    
    let httpReq = HTTPRequest(method: request.httpMethod, url: urlComponents.url!.absoluteString)
    
    let _ = HTTPClient.connect(scheme: .https, hostname: request.hostName, on: wsClientWorker).do { client in
      let _ = client.send(httpReq).do({ httpResponse in
        if let data = httpResponse.body.data,
          let parsedAny = try? JSONSerialization.jsonObject(with:
            data, options: []),
          let array = parsedAny as? [Any] {
          completion?(array)
        } else {
          print("error parsing array json:", httpResponse.body)
        }
      }).catch({ (error) in
        print("err:",error)
      })
      }.catch { (error) in
        print("err:",error)
    }
  }
  
}

