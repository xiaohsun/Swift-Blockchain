//
//  Block.swift
//  SwiftBlockchain
//
//  Created by 徐柏勳 on 5/11/25.
//

import Foundation

struct Block: Codable {
    let index: Int
    let timestamp: Double
    let transactions: [Transaction]
    let proof: Int
    let previousHash: String
}
