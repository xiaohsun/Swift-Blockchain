//
//  ApiResponses.swift
//  SwiftBlockchain
//
//  Created by 徐柏勳 on 5/11/25.
//

import Vapor
import Foundation

struct ChainResponse: Content {
    let chain: [Block]
    let length: Int
}

struct MineResponse: Content {
    let message: String
    let index: Int
    let transactions: [Transaction]
    let proof: Int
    let previousHash: String
}

struct TransactionResponse: Content {
    let message: String
}

struct NodesResponse: Content {
    let message: String
    let totalNodes: [String]
}

struct ReplacedChainResponse: Content {
    let message: String
    let newChain: [Block]
}

struct AuthoritativeChainResponse: Content {
    let message: String
    let chain: [Block]
}

struct ErrorResponse: Content {
    let message: String
} 
