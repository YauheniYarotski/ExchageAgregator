
import Vapor

let wsClientWorker = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public func sockets(_ websockets: NIOWebSocketServer) {
  // Status
  
  websockets.get("echo-test") { ws, req in
    print("ws connnected")
    ws.onText { ws, text in
      print("ws received: \(text)")
      ws.send("echo - \(text)")
    }
  }
  
  // Listener
  
//  websockets.get("listen", TrackingSession.parameter) { ws, req in
//    // 2
//    print("connected to WS:", ws, req)
//    let session = try req.parameters.next(TrackingSession.self)
//    // 3
//    guard sessionManager.sessions[session] != nil else {
//      print("no sessions for session:", session)
//      ws.close()
//      return
//    }
//    // 4
//    sessionManager.add(listener: ws, to: session)
//  }
  
  websockets.get("books") { ws, req in
    // 2
    print("client connected to WS")
    operationManager.sessionManager.add(listener: ws)
  }
}
