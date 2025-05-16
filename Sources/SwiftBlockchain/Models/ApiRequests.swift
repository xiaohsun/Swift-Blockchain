//
//  ApiRequests.swift
//  SwiftBlockchain
//
//  Created by 徐柏勳 on 5/11/25.
//

import Vapor
import Foundation

struct TransactionRequest: Content {
    let sender: String
    let recipient: String
    let amount: Int
}

struct NodesRequest: Content {
    let nodes: [String]
} 
