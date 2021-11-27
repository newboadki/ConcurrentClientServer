//
//  SwiftCService.swift
//  ConcurrentClientServer (iOS)
//
//  Created by Borja Arias Drake on 24.11.2021..
//

import Foundation

@LoadBalancerActor
/// The service runs in the @LoadBalancerActor global actor. This is so that any load balaning decisions are made synchronously.
/// In particular, this means accessing the service's task load synchronously.
class SwiftCService: QueueDelegate {
        
    let id: String
    
    let supportedRequestTypes: [ServiceRequest.RequestType]
    
    /// Services that have the same priority won't run concurrently
    let priority: TaskPriority
    
    @Published
    /// A way for the service to communicate that its load changed
    var loadInfoPublisher: ServiceLoadInfo = ServiceLoadInfo(serviceId: "NULL", currentItemsCount: 0)
    
    
    // MARK: Private properties
    
    /// A multiple of this amount is used in the body of a task representing an incoming request.
    private let delay: UInt32
    
    /// Tasks are executed in FIFO order
    private let serialQueue: AsyncSerialQueue
    
    
    // MARK: Private Initializers
    
    nonisolated init(id: String, priority: TaskPriority, supportedRequestTypes: [ServiceRequest.RequestType], delay: UInt32) {
        self.id = id
        self.priority = priority
        self.supportedRequestTypes = supportedRequestTypes
        self.delay = delay
        self.serialQueue = AsyncSerialQueue(id: self.id)
        Task {await self.serialQueue.setTaskComletionDelegate(self)}
    }
    
    // MARK: Public API
    
    func process(request: ServiceRequest) {
        // We want to enqueue and forget, so that we can continue to handle more requests.
        // => Create an unstructure task, so we don't wait for its completion.
        // => It has to be detached, because we are in @LoadBalancerActor, so that the new tasks don't inherit the actor and the enqueing can happen async
        Task.detached(priority:self.priority) {
            await self.serialQueue.process {
                await Task.sleep(UInt64(self.delay) * 1_000_000_000)
                (1...500).forEach { _ in
                    if Task.isCancelled { return }
                    // Do work
                }
                await Task.sleep(UInt64(self.delay) * 1_000_000_000)
            }
        }
    }
    
    func workLoad() -> Int {
        return loadInfoPublisher.currentItemsCount
    }
    
    func cancel() {
        Task {
            await self.serialQueue.cancel()
        }
    }

    // MARK: QueueDelegate
    
    func taskCountChanged(_ newValue: Int) async {
        self.loadInfoPublisher = ServiceLoadInfo(serviceId: self.id, currentItemsCount: newValue)
    }
    
    // MARK: - Private helpers
    
    private func increasedByOneLoadInfo() -> ServiceLoadInfo {
        return ServiceLoadInfo(serviceId: id, currentItemsCount: loadInfoPublisher.currentItemsCount + 1)
    }
}
