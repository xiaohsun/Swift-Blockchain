import Vapor
import Logging
import NIOCore
import NIOPosix

@main
struct BlockchainApp {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        
        do {
            try configure(app)
            
            let blockchainController = BlockchainController()
            blockchainController.registerRoutes(app)
            
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}
