import Vapor


/// Register your application's routes here.
public func routes(_ router: Router) throws {

  router.get("status") { _ in "ok \(Date())" }
  
  
  
  // MARK: Poster Routes
  
//  router.post("create", use: sessionManager.createTrackingSession)
  
//  router.post("close", TrackingSession.parameter) { req -> HTTPStatus in
//    let session = try req.parameters.next(TrackingSession.self)
//    sessionManager.close(session)
//    return .ok
//  }
//  
//  router.post("update") { req -> Future<HTTPStatus> in
//    return try ExchangesBooks.decode(from: req).map(to: HTTPStatus.self) { exchangesBooks in
//      sessionManager.update(exchangesBooks)
//      return .ok
//      }.catch({ (error) in
//        print(error.localizedDescription)
//      })
//  }
//
  
  let websiteController = WebsiteController()
  try router.register(collection: websiteController)
}
