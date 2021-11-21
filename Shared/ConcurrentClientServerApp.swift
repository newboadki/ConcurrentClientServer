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
            QueueContainerView(presenter: QueuesContainerPresenter(balancer: GCDLoadBalancer(services: baseServiceConfiguration())))
        }
    }
}

func baseServiceConfiguration() -> [ServiceRequest.RequestType : [GCDService]] {
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
