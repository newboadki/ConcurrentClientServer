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
    let service: GCDService
    private let balancer: GCDLoadBalancer
    
    init() {
        self.balancer = GCDLoadBalancer()
        self.service = balancer.firstService(forRequestType: .A)
        self.queueViewModels = [QueueViewModel(presenter: QueuePresenter(serviceId: service.id,
                                                                         serviceLoadPublisher: AnyPublisher(service.$loadInfo)))]
    }
    
    func start() {
        pushToService()
    }
    
    func pushToService() {
        DispatchQueue.global(qos: .default).async {
            for _ in 1...5 {
                sleep(1)
                self.service.process(request: ServiceRequest(type: .A))
            }
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
