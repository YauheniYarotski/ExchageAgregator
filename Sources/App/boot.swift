import Vapor

let operationManager = OperationManager()

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Your code here
  operationManager.start(app)
}


