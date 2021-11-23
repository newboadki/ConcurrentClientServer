//
//  OperationQueueService.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 23.11.2021..
//

import Foundation

class OperationQueueService: Service {
    
    // MARK: Service properties
    
    var id: String
    var supportedRequestTypes: [ServiceRequest.RequestType]
    var loadInfoPublisher: Published<ServiceLoadInfo>.Publisher {
        $loadInfo
    }
    
    // MARK: Private properties
    
    @Published private var loadInfo: ServiceLoadInfo
    private let delay: UInt32
    private let operationQueue: OperationQueue
    private var kvoToken: NSKeyValueObservation?
        
    // MARK: Initializers
    
    init(id: String, supportedRequestTypes: [ServiceRequest.RequestType], delay: UInt32) {
        self.id = id
        self.supportedRequestTypes = supportedRequestTypes
        self.delay = delay
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.loadInfo = ServiceLoadInfo(serviceId: id, currentItemsCount: 0)
        self.observeOperationCount()
    }
    
    deinit {
        kvoToken?.invalidate()
    }
    
    // MARK: Service protocol conformance
    
    func process(request: ServiceRequest) {
        operationQueue.addOperation(DummyCancellableOperation(id: self.id, delay: self.delay))
        loadInfo = ServiceLoadInfo(serviceId: id, currentItemsCount: Int(self.workLoad()))
    }
    
    func workLoad() -> Int {
        let count = operationQueue.operationCount
        return Int(count)
    }
    
    func cancel() {
        operationQueue.cancelAllOperations()
        loadInfo = ServiceLoadInfo(serviceId: id, currentItemsCount: self.workLoad())
    }
    
    // MARK: KVO
        
    func observeOperationCount() {
        kvoToken = operationQueue.observe(\.operationCount, options: .new) { (queue, change) in
            guard let count = change.newValue else { return }
            print("WORKLOAD \(count)")
            self.loadInfo = ServiceLoadInfo(serviceId: self.id, currentItemsCount: self.workLoad())
        }
    }
}
