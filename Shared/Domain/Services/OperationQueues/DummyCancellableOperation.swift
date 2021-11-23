//
//  DummyCancellableOperationQueue.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 23.11.2021..
//

import Foundation

class DummyCancellableOperation: Operation {

    // MARK: Public properties
    override var isFinished: Bool {
        get {
            return _isFinished
        }
    }

    override var isExecuting: Bool {
        get {
            return _isExecuting
        }
    }

    // MARK: Private properties
    
    private var id: String
    private let delay: UInt32
        
    private var _isFinished: Bool = false {
        willSet {
            self.willChangeValue(for: \.isFinished)
        }
        
        didSet {
            self.didChangeValue(for: \.isFinished)
        }
    }
    
    private var _isExecuting: Bool = false {
        willSet {
            self.willChangeValue(for: \.isExecuting)
        }
        
        didSet {
            self.didChangeValue(for: \.isExecuting)
        }
    }
    
    // MARK: Initializers
    
    init(id: String, delay: UInt32) {
        self.id = id
        self.delay = delay
    }
    
    override func start() {
        _isExecuting = true
        
        sleep(self.delay)
        for i in 1...10_000 {
            guard !self.isCancelled else {
                self._isExecuting = false
                self._isFinished = true
                return
            }
            print("\(id)-Working...\(i)")
        }
        sleep(self.delay)
                    
        self._isExecuting = false
        self._isFinished = true
    }
}
