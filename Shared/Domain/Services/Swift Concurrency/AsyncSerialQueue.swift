//
//  AsyncSerialQueue.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 25.11.2021..
//

import Foundation

/// Executes asynchronous tasks serially.
/// Requests will be enqueued as they arrive, but they'll execute in FIFO order once the previous task has finished.
/// Tasks are executed in a unstructured but scoped task.
actor AsyncSerialQueue: SerialExecutor {
    
    typealias AsyncProcedure = () async -> Void

    // MARK: Private properties
    
    private var state: SerialExecutorState
    private var requests: [AsyncProcedure]
    private var delegate: QueueDelegate?
    private var id: String
    
    // MARK: Initializers
    
    init(id: String) {
        self.state = .idle
        self.requests = []
        self.id = id
    }
    
    // MARK: SerialExecutor
    
    func state() async -> SerialExecutorState {
        return self.state
    }
    
    func count() async -> Int {
        return requests.count
    }
    
    func setTaskComletionDelegate(_ delegate: QueueDelegate) async {
        self.delegate = delegate
    }
        
    func process(_ block: @escaping AsyncProcedure) async {        
        self.requests.append(block)
        await self.delegate?.taskCountChanged(requests.count)
        
        switch state {
            case .idle: break
            case .running: return
        }
        
        while !requests.isEmpty {
            await executeNextRequest()
        }
    }
    
    func cancel() async {
        switch state {
            case .running(let task):
                task.cancel()
            default: break
        }
        
        self.requests.removeAll()
    }
    
    // MARK: Helpers
    
    private func executeNextRequest() async {
        guard let block = self.requests.first else {
            return
        }
        
        let task = Task { await block() }
        state = .running(task)
        _ = await task.result
        state = .idle
        
        if !requests.isEmpty {
            requests.remove(at: 0)
        }
        await self.delegate?.taskCountChanged(requests.count)
    }
}
