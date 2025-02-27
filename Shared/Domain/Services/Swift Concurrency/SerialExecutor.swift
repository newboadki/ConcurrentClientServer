//
//  SerialExecutor.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 25.11.2021..
//

import Foundation

enum SerialExecutorState {
    case idle
    case running(Task<Void, Never>)
}

protocol QueueDelegate: Sendable {
    func taskCountChanged(_ newValue: Int) async
}

protocol SerialExecutor: Sendable {

	func setDelay(_ delay: Int64) async
	
    func setTaskComletionDelegate(_ delegate: QueueDelegate) async
    
    func state() async -> SerialExecutorState
    
    /// Number of tasks in the queue
    func count() async -> Int
    
    func process(_ block: AsyncProcedure) async
    
    func cancel() async
}
