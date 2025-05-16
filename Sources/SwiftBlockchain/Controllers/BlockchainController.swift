//
//  BlockchainController.swift
//  SwiftBlockchain
//
//  Created by 徐柏勳 on 5/11/25.
//

import Vapor
import Foundation

struct BlockchainController: Sendable {
    let blockchain = Blockchain()
    // Your node UUID
    let nodeIdentifier = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    
    func registerRoutes(_ app: Application) {
        // Get the complete chain
        app.get("chain", use: getChain)
        
        // Mine
        app.get("mine", use: mine)
        
        // Create new transaction
        app.post("transactions", "new", use: createTransaction)
        
        // Register new nodes
        app.post("nodes", "register", use: registerNodes)
        
        // Resolve conflicts
        app.get("nodes", "resolve", use: resolveConflicts)
    }
    
    // Get the complete chain
    func getChain(_ req: Request) async throws -> Response {
        let chainResponse = ChainResponse(
            chain: blockchain.chain,
            length: blockchain.chain.count
        )
        
        return try await chainResponse.encodeResponse(for: req)
    }
    
    /// Mine, create a new block and add it to the chain
    func mine(_ req: Request) async throws -> Response {
        // Calculate Proof of Work
        let lastBlock = blockchain.lastBlock
        let lastProof = lastBlock.proof
        let proof = blockchain.proofOfWork(lastProof: lastProof)
        
        // recipient being "0" means the miner has received a new coin
        _ = blockchain.newTransaction(
            sender: "0",
            recipient: nodeIdentifier,
            amount: 1
        )
        
        // Add the new Block to the end of the chain
        let previousHash = Blockchain.hash(block: lastBlock)
        let block = blockchain.newBlock(proof: proof, previousHash: previousHash)
        
        let mineResponse = MineResponse(
            message: "New Block Forged",
            index: block.index,
            transactions: block.transactions,
            proof: block.proof,
            previousHash: block.previousHash
        )
        
        return try await mineResponse.encodeResponse(for: req)
    }
    
    /// Create a new transaction and add it to the waiting area
    func createTransaction(_ req: Request) async throws -> Response {
        guard let content = try? req.content.decode(TransactionRequest.self) else {
            let response = ErrorResponse(message: "Missing required values")
            return try await response.encodeResponse(status: .badRequest, for: req)
        }
        
        let index = blockchain.newTransaction(
            sender: content.sender,
            recipient: content.recipient,
            amount: content.amount
        )
        
        let response = TransactionResponse(message: "Transaction will be added to Block \(index)")
        return try await response.encodeResponse(status: .created, for: req)
    }
    
    // Register new nodes to the network
    func registerNodes(_ req: Request) async throws -> Response {
        guard let content = try? req.content.decode(NodesRequest.self),
              !content.nodes.isEmpty else {
            let response = ErrorResponse(message: "Please provide a valid list of nodes")
            return try await response.encodeResponse(status: .badRequest, for: req)
        }
        
        for node in content.nodes {
            blockchain.registerNode(address: node)
        }
        
        let response = NodesResponse(
            message: "New nodes have been added",
            totalNodes: Array(blockchain.nodes)
        )
        
        return try await response.encodeResponse(status: .created, for: req)
    }
    
    /// Resolve chain conflicts between nodes
    func resolveConflicts(_ req: Request) async throws -> Response {
        let replaced = try await blockchain.resolveConflicts()
        
        if replaced {
            let response = ReplacedChainResponse(
                message: "My chain will be replaced",
                newChain: blockchain.chain
            )
            
            return try await response.encodeResponse(for: req)
        } else {
            let response = AuthoritativeChainResponse(
                message: "My chain is the longest chain",
                chain: blockchain.chain
            )
            
            return try await response.encodeResponse(for: req)
        }
    }
}
