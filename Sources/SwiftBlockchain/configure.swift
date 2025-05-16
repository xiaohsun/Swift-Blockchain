import Vapor

public func configure(_ app: Application) throws {
    let blockchainController = BlockchainController()
    blockchainController.registerRoutes(app)
    
    app.http.server.configuration.port = 8080
}
