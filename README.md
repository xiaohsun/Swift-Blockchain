# Blockchain Server in Swift

A lightweight blockchain implementation written in Swift using the Vapor framework. This project demonstrates the core concepts of blockchain technology including mining, transactions, and consensus mechanisms.
<br/>
<br/>
 
## Overview

This repository implements a blockchain with the following features:
- Proof of Work algorithm
- Transaction validation
- Consensus mechanism for distributed nodes
- RESTful API for interaction

This implementation is inspired by the concepts outlined in the article [Learn Blockchains by Building One](https://hackernoon.com/learn-blockchains-by-building-one-117428612f46) by Daniel van Flymen, adapted to Swift and the Vapor framework.
<br/>
<br/>

## Requirements

- Swift 5.8+
- macOS or Linux
<br/>
<br/>
 
## Getting Started
  
  
### Build the Project

```bash
swift build
```
  
  
### Run the Server

```bash
swift run
```

The blockchain server will start on port 8080 by default.
<br/>
<br/>

## API Usage

You can interact with the blockchain API using cURL, Postman, or any HTTP client.
  
  
### View the Blockchain

```bash
curl http://localhost:8080/chain
```
  
  
### Mine a New Block

```bash
curl http://localhost:8080/mine
```
  
  
### Create a New Transaction

```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "sender": "sender-address",
    "recipient": "recipient-address",
    "amount": 5
}' http://localhost:8080/transactions/new
```
  
  
### Register New Nodes

```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "nodes": ["http://localhost:8081"]
}' http://localhost:8080/nodes/register
```
  
  
### Resolve Consensus Issues

```bash
curl http://localhost:8080/nodes/resolve
```
<br/>

## Testing Multiple Nodes

To test the consensus mechanism, you need to run multiple nodes on different ports:
  
  
### Configure and Run a Second Node

Modify the port configuration in `configure.swift` for the second node:

```swift
// In the second node's configure.swift
app.http.server.configuration.port = 8081
```

Run the second node:

```bash
swift run --working-directory /path/to/second/node
```
  
  
### Register Nodes with Each Other

Register the second node with the first node:

```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "nodes": ["http://localhost:8081"]
}' http://localhost:8080/nodes/register
```

Register the first node with the second node:

```bash
curl -X POST -H "Content-Type: application/json" -d '{
    "nodes": ["http://localhost:8080"]
}' http://localhost:8081/nodes/register
```
  
  
### Test Consensus

Mine a few blocks on the first node:

```bash
curl http://localhost:8080/mine
curl http://localhost:8080/mine
```

Then invoke the consensus mechanism on the second node:

```bash
curl http://localhost:8081/nodes/resolve
```

This will synchronize node 2 with node 1, accepting the longer chain from node 1.
<br/>
<br/>

## Contact
Author: Bo-Hsun Hsu
Email: bohsunhsu@gmail.com
<br/>
<br/>

## License

This project is available under the MIT License.
