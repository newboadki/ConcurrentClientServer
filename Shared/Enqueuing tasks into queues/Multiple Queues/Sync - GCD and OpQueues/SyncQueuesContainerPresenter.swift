//
//  QueuesContainerPresenter.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 18.11.2021..
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SyncQueuesContainerPresenter: QueuesContainerPresenterProtocol {

    var queueViewModelsPublisher: Published<[QueueViewModel]>.Publisher {
        return $_queueViewModels
    }
    
    @Published private var _queueViewModels: [QueueViewModel]
    
    private let balancer: LoadBalancer
    
    init(balancer: LoadBalancer) {
        self.balancer = balancer
        self._queueViewModels = []
    }

	func setup() async {
		for aService in self.balancer.serviceList {
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
			let model = await QueueViewModel(presenter: QueuePresenter(serviceId: aService.id, serviceLoadPublisher: aService.loadInfoSequence), baseColor: color)

			self._queueViewModels.append(model)
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
