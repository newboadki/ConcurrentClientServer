//
//  AsyncQueuesContainerPresenter.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 25.11.2021..
//

import SwiftUI
import Combine

@MainActor
class AsyncQueuesContainerPresenter: ObservableObject, QueuesContainerPresenterProtocol {
    
    var queueViewModelsPublisher: Published<[QueueViewModel]>.Publisher {
        return $_queueViewModels
    }
    
    @Published private var _queueViewModels: [QueueViewModel]
        
    private let balancer: AsyncCurrentMinLoadBalancerProxy
    
    init(balancer: AsyncCurrentMinLoadBalancerProxy) {
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
			let viewModel = await QueueViewModel(presenter: QueuePresenter(serviceId: aService.id, serviceLoadPublisher: aService.loadInfoSequence), baseColor: color)
			_queueViewModels.append(viewModel)
		}
	}

	func startA() {
		submitRequests(n: 5, type: .A)
	}

	func startB() {
		submitRequests(n: 5, type: .B)
	}

	func startC() {
		submitRequests(n: 5, type: .C)
	}

	func cancel() {
		Task {
			await balancer.cancel()
        }
    }

	private func submitRequests(n: Int, type: ServiceRequest.RequestType) {		
		for _ in 1...n {
			Task.detached {
				await self.balancer.process(request: ServiceRequest(type: type))
				/*
				 Becuase the service runs tasks in a serial queue actor, requesting the current queue task count is an async operation.
				 The queue task count for a given service is used by the load balancer to decide the service that should receive a new request.
				 If the requests are fired rapidly, as in with no delay in the for-loop, then there's no time for the serial queue to update its count,
				 therefore the balancer works with the latest known value, resulting in multiple requests going to the same service even if there are others free.
				 */
				try? await Task.sleep(nanoseconds: 1_000_000_000)
			}
		}
	}
}
