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
            QueueContainerView(presenter: QueuesContainerPresenter(balancer: GCDLoadBalancer()))
        }
    }
}
