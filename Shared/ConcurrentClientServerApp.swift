//
//  ConcurrentClientServerApp.swift
//  Shared
//
//  Created by Borja Arias Drake on 17.11.2021..
//

import SwiftUI

@main
struct ConcurrentClientServerApp: App {
    var body: some Scene {
        WindowGroup {
            // GCD
            //QueueContainerView(presenter: QueuesContainerPresenter(basePresenter: SyncQueuesContainerPresenter(balancer: CurrentMinLoadBalancer(services: baseGCDServiceConfiguration()))))
            
            // Operation Queues
            // QueueContainerView(presenter: QueuesContainerPresenter(basePresenter: SyncQueuesContainerPresenter(balancer: CurrentMinLoadBalancer(services: baseOperationQueueServiceConfiguration()))))
            
            // Swift Concurrency
            QueueContainerView(presenter: QueuesContainerPresenter(basePresenter: AsyncQueuesContainerPresenter(balancer: AsyncCurrentMinLoadBalancerProxy(services: baseSwiftConcurrencyServiceConfiguration()))))
        }
    }
}

func baseGCDServiceConfiguration() -> [ServiceRequest.RequestType : [GCDService]] {
    let A1 = GCDService(id: "A1", supportedRequestTypes: [.A], delay: 2)
    let A2 = GCDService(id: "A2", supportedRequestTypes: [.A], delay: 5)
    let B = GCDService(id: "B", supportedRequestTypes: [.B], delay: 1)
    let C1 = GCDService(id: "C1", supportedRequestTypes: [.C], delay: 2)
    let C2 = GCDService(id: "C2", supportedRequestTypes: [.C], delay: 1)
    let C3 = GCDService(id: "C3", supportedRequestTypes: [.C], delay: 3)
    
    return  [.A : [A1, A2],
             .B : [B],
             .C : [C1, C2, C3]]
}

func baseOperationQueueServiceConfiguration() -> [ServiceRequest.RequestType : [OperationQueueService]] {
    let A1 = OperationQueueService(id: "A1", supportedRequestTypes: [.A], delay: 2)
    let A2 = OperationQueueService(id: "A2", supportedRequestTypes: [.A], delay: 5)
    let B = OperationQueueService(id: "B", supportedRequestTypes: [.B], delay: 1)
    let C1 = OperationQueueService(id: "C1", supportedRequestTypes: [.C], delay: 2)
    let C2 = OperationQueueService(id: "C2", supportedRequestTypes: [.C], delay: 1)
    let C3 = OperationQueueService(id: "C3", supportedRequestTypes: [.C], delay: 3)
    
    return  [.A : [A1, A2],
             .B : [B],
             .C : [C1, C2, C3]]
}

func baseSwiftConcurrencyServiceConfiguration() -> [ServiceRequest.RequestType : [SwiftCService]] {
    let A1 = SwiftCService(id: "A1", priority: .low, supportedRequestTypes: [.A], delay: 5)
    let A2 = SwiftCService(id: "A2", priority: .medium, supportedRequestTypes: [.A], delay: 5)
    let B = SwiftCService(id: "B", priority: .background, supportedRequestTypes: [.B], delay: 5)
    let C1 = SwiftCService(id: "C1", priority: .medium, supportedRequestTypes: [.C], delay: 4)
    let C2 = SwiftCService(id: "C2", priority: .low, supportedRequestTypes: [.C], delay: 1)
    let C3 = SwiftCService(id: "C3", priority: .high, supportedRequestTypes: [.C], delay: 6)
    
    return  [.A : [A1, A2],
             .B : [B],
             .C : [C1, C2, C3]]
}
