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
        Task {
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
                let viewModel = await QueueViewModel(presenter: QueuePresenter(serviceId: aService.id, serviceLoadPublisher: AnyPublisher(aService.$loadInfoPublisher)), baseColor: color)
                _queueViewModels.append(viewModel)
            }
        }
    }
    
    func startA() {
        DispatchQueue.global(qos: .default).async {
            Task {
                for i in 1...5 {
                    await self.balancer.process(request: ServiceRequest(type: .A, id: "\(i)"))
                    /*
                     Becuase the service runs tasks in a serial queue actor, requesting the current queue task count is an async operation.
                     The queue task count for a given service is used by the load balancer to decide the service that should receive a new request.
                     If the requests are fired rapidly, as in with no delay in the for-loop, then there's no time for the serial queue to update its count,
                     therefore the balancer works with the latest known value, resulting in multiple requests going to the same service even if there are others free.
                     */
                    await Task.sleep(1)
                }
            }
        }
    }
    
    func startB() {
        DispatchQueue.global(qos: .default).async {
            Task {
                for _ in 1...5 {
                    await self.balancer.process(request: ServiceRequest(type: .B))
                    await Task.sleep(1)
                }
            }
        }
    }
    
    func startC() {
        DispatchQueue.global(qos: .default).async {
            Task {
                for _ in 1...5 {
                    await self.balancer.process(request: ServiceRequest(type: .C))
                    await Task.sleep(1)
                }
            }
        }
    }
    
    func cancel() {
        Task {
            await balancer.cancel()
        }
    }
}
