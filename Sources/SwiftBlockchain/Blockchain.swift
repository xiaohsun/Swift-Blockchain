//
//  Blockchain.swift
//  SwiftBlockchain
//
//  Created by 徐柏勳 on 5/11/25.
//

import Foundation
import CryptoKit

class Blockchain: @unchecked Sendable {
    private(set) var chain: [Block] = []
    private(set) var currentTransactions: [Transaction] = []
    private(set) var nodes: Set<String> = []
    
    /// Get the last Block in the chain
    var lastBlock: Block {
        return chain.last!
    }
    
    init() {
        // Genesis block
        _ = newBlock(proof: 100, previousHash: "1")
    }

    /// Create a new Block and append it to the chain
    func newBlock(proof: Int, previousHash: String? = nil) -> Block {
        let block = Block(
            index: chain.count + 1,
            timestamp: Date().timeIntervalSince1970,
            transactions: currentTransactions,
            proof: proof,
            previousHash: previousHash ?? Blockchain.hash(block: chain.last!)
        )
        
        // Clear the Transactions waiting area
        currentTransactions = []
        
        // Attach the new Block to the end of the chain
        chain.append(block)
        
        return block
    }
    
    /// Create a new transaction and add it to the waiting area
    func newTransaction(sender: String, recipient: String, amount: Int) -> Int {
        let transaction = Transaction(
            sender: sender,
            recipient: recipient,
            amount: amount
        )
        
        currentTransactions.append(transaction)
        
        // Index of the block that will include this transaction (the next one to be mined)
        return lastBlock.index + 1
    }
    
    /// Register a new node
    /// - address: Node address, e.g. "http://192.168.0.5:5000"
    func registerNode(address: String) {
        if let url = URL(string: address), let host = url.host {
            let node = url.port != nil ? "\(host):\(url.port!)" : host
            nodes.insert(node)
        }
    }
    
    /// Resolve conflicts between nodes
    /// Returns true if our chain was replaced
    func resolveConflicts() async throws -> Bool {
        var newChain: [Block]? = nil
        var maxLength = chain.count
        
        // Get and verify the chains from all nodes in the network
        for node in nodes {
            let urlString = "http://\(node)/chain"
            guard let url = URL(string: urlString) else { continue }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                continue
            }
            
            let decoder = JSONDecoder()
            let chainResponse = try decoder.decode(ChainResponse.self, from: data)
            
            // Check if the chain is longer and valid
            if chainResponse.length > maxLength && Blockchain.validChain(chain: chainResponse.chain) {
                maxLength = chainResponse.length
                newChain = chainResponse.chain
            }
        }
        
        // If we found a longer valid chain, replace our chain
        if let newChain = newChain {
            chain = newChain
            return true
        }
        
        return false
    }
    
    /// Find a PoW value
    func proofOfWork(lastProof: Int) -> Int {
        var proof = 0
        
        while !Blockchain.validProof(lastProof: lastProof, proof: proof) {
            proof += 1
        }
        
        return proof
    }
    
    /// Compute the hash value for a Block
    static func hash(block: Block) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        guard let blockData = try? encoder.encode(block) else {
            return ""
        }
        
        let hash = SHA256.hash(data: blockData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify if the Proof of Work is correct
    static func validProof(lastProof: Int, proof: Int) -> Bool {
        let guess = "\(lastProof)\(proof)".data(using: .utf8)!
        let hash = SHA256.hash(data: guess)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        // Check if the hash value starts with 4 zeros
        return hashString.prefix(4) == "0000"
    }
    
    /// Verify if the Blockchain is valid
    static func validChain(chain: [Block]) -> Bool {
        guard !chain.isEmpty else { return false }
        
        var lastBlock = chain[0]
        var currentIndex = 1
        
        while currentIndex < chain.count {
            let block = chain[currentIndex]
            
            // Check if the Block's hash value is correct
            if block.previousHash != Blockchain.hash(block: lastBlock) {
                return false
            }
            
            // Check if the Proof of Work is correct
            if !Blockchain.validProof(lastProof: lastBlock.proof, proof: block.proof) {
                return false
            }
            
            lastBlock = block
            currentIndex += 1
        }
        
        return true
    }
}
