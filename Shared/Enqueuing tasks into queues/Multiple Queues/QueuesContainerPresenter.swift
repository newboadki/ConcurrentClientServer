//
//  Main.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 18.11.2021..
//

import Foundation
import Combine
import SwiftUI

struct QueueViewModel: Identifiable {
    
    var id: String {
        presenter.serviceId
    }
    
    let presenter: QueuePresenter
    let baseColor: Color
}

class QueuesContainerPresenter: ObservableObject {
        
    @Published var queueViewModels: [QueueViewModel]
    private let balancer: GCDLoadBalancer
    
    init(balancer: GCDLoadBalancer) {
        self.balancer = balancer
        self.queueViewModels = []
        self.queueViewModels = self.balancer.serviceList.map { aService in
            var color: Color = .yellow
            if let type = aService.supportedRequestTypes.first {
                switch type {
                case .A:
                    color = .red
                case .B:
                    color = .blue
                case .C:
                    color = .orange
                }
            }
            return QueueViewModel(presenter: QueuePresenter(serviceId: aService.id, serviceLoadPublisher: AnyPublisher(aService.$loadInfo)), baseColor: color)
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
