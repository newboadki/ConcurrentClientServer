//
//  Main.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 18.11.2021..
//

import Foundation
import Combine

struct QueueViewModel: Identifiable {
    
    var id: String {
        presenter.serviceId
    }
    
    let presenter: QueuePresenter
}

class QueuesContainerPresenter: ObservableObject {
        
    @Published var queueViewModels: [QueueViewModel]
    private let balancer: GCDLoadBalancer
    
    init() {
        self.balancer = GCDLoadBalancer()
        self.queueViewModels = []
        self.queueViewModels = self.balancer.serviceList.map { aService in
            QueueViewModel(presenter: QueuePresenter(serviceId: aService.id, serviceLoadPublisher: AnyPublisher(aService.$loadInfo)))
        }
    }
    
    func startA() {
        DispatchQueue.global(qos: .default).async {
            for _ in 1...5 {
                self.balancer.handle(request: ServiceRequest(type: .A))
            }
        }
    }
    
    func startB() {
        DispatchQueue.global(qos: .default).async {
            for _ in 1...5 {
                self.balancer.handle(request: ServiceRequest(type: .B))
            }
        }
    }
    
    func startC() {
        DispatchQueue.global(qos: .default).async {
            for _ in 1...5 {
                self.balancer.handle(request: ServiceRequest(type: .C))
            }
        }
    }
}
