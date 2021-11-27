//
//  QueuesContainerPresenter.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 18.11.2021..
//

import Foundation
import Combine
import SwiftUI

class SyncQueuesContainerPresenter: QueuesContainerPresenterProtocol {
        
    var queueViewModelsPublisher: Published<[QueueViewModel]>.Publisher {
        return $_queueViewModels
    }
    
    @Published private var _queueViewModels: [QueueViewModel]
    
    private let balancer: LoadBalancer
    
    init(balancer: LoadBalancer) {
        self.balancer = balancer
        self._queueViewModels = []
        self._queueViewModels = self.balancer.serviceList.map { aService in
            var color: Color = .yellow
            if let type = aService.supportedRequestTypes.first {
                switch type {
                case .A:
                    color = Color.CyberRetro.pink()
                case .B:
                    color = Color.CyberRetro.blue()
                case .C:
                    color = Color.CyberRetro.green()
                }
            }
            return QueueViewModel(presenter: QueuePresenter(serviceId: aService.id, serviceLoadPublisher: AnyPublisher(aService.loadInfoPublisher)), baseColor: color)
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
    
    func cancel() {
        balancer.cancel()
    }
}
