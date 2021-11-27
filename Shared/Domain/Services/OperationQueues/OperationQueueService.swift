//
//  OperationQueueService.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 23.11.2021..
//

import Foundation

class OperationQueueService: Service {
    
    // MARK: Service properties
    
    let id: String
    let supportedRequestTypes: [ServiceRequest.RequestType]
    var loadInfoPublisher: Published<ServiceLoadInfo>.Publisher {
        $loadInfo
    }
    
    // MARK: Private properties
    
    @Published private var loadInfo: ServiceLoadInfo
    private let delay: UInt32
    private let operationQueue: OperationQueue
    private let workLoadOperationQueue: OperationQueue
    private var kvoToken: NSKeyValueObservation?
        
    // MARK: Initializers
    
    init(id: String, supportedRequestTypes: [ServiceRequest.RequestType], delay: UInt32) {
        self.id = id
        self.supportedRequestTypes = supportedRequestTypes
        self.delay = delay
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.workLoadOperationQueue = OperationQueue()
        self.workLoadOperationQueue.maxConcurrentOperationCount = 1
        self.loadInfo = ServiceLoadInfo(serviceId: id, currentItemsCount: 0)
        self.observeOperationCount()
    }
    
    deinit {
        kvoToken?.invalidate()
    }
    
    // MARK: Service protocol conformance
    
    func process(request: ServiceRequest) {
        let op = DummyCancellableOperation(id: self.id, delay: self.delay)
        op.completionBlock = {
            print("OP FINISHED")
        }
        operationQueue.addOperation(op)
    }
    
    func workLoad() -> Int {
        let count = operationQueue.operationCount
        return Int(count)
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
    }
    
    // MARK: KVO
        
    func observeOperationCount() {
        kvoToken = operationQueue.observe(\.operationCount, options: .new) { (queue, change) in
            // We should synchronise access to this property.
            // Currently the queue is serial, really minimizing the changes of race conditions over this var.
            // However, in concurrent queues, I assume access to operationCount is already thread-safe,
            // But KVO schedule updates this thread that sends the KVO notification.
            self.workLoadOperationQueue.addOperation {
                self.loadInfo = ServiceLoadInfo(serviceId: self.id, currentItemsCount: self.workLoad())
            }
        }
    }
}
