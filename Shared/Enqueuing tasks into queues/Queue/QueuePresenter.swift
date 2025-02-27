//
//  QueuePresenter.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 20.11.2021..
//

import SwiftUI
import Combine

@MainActor
class QueuePresenter: ObservableObject {

    @Published var items: [QueueItemViewModel]
    
    let serviceId: String
    private let serviceLoadPublisher: AsyncStream<ServiceLoadInfo>
    private var serviceLoadSubscription: AnyCancellable?
    private var lastTaskCount: Int = 0
    
    init(serviceId: String, serviceLoadPublisher: AsyncStream<ServiceLoadInfo>) async {
        self.serviceId = serviceId
        self.serviceLoadPublisher = serviceLoadPublisher
        self.items = [QueueItemViewModel(id: serviceId + "0", state: .none),
                      QueueItemViewModel(id: serviceId + "1", state: .none),
                      QueueItemViewModel(id: serviceId + "2", state: .none),
                      QueueItemViewModel(id: serviceId + "3", state: .none),
                      QueueItemViewModel(id: serviceId + "4", state: .none),
                      QueueItemViewModel(id: serviceId + "5", state: .none),
                      QueueItemViewModel(id: serviceId + "6", state: .none),
                      QueueItemViewModel(id: serviceId + "7", state: .none),
                      QueueItemViewModel(id: serviceId + "8", state: .none),
                      QueueItemViewModel(id: serviceId + "9", state: .none),
                      QueueItemViewModel(id: serviceId + "10", state: .none),
                      QueueItemViewModel(id: serviceId + "11", state: .none)]
		await self.subscribeForLoadUpdates()
    }
    
	private func subscribeForLoadUpdates() async {
		Task {
			for await newLoadInfo in serviceLoadPublisher {
				guard newLoadInfo.currentItemsCount >= 0 else {
					return
				}
				
				let additionalCount = newLoadInfo.currentItemsCount - self.lastTaskCount
				if additionalCount > 0 {
					for _ in 1...additionalCount {
						self.items.append(QueueItemViewModel(id: self.serviceId + "\(self.items.count)", state: .none))
					}
					
					for _ in 1...additionalCount {
						self.enqueue()
					}
				} else if additionalCount < 0 {
					for _ in 1...(additionalCount * -1 ) {
						self.dequeue()
					}
				}
				
				self.lastTaskCount = newLoadInfo.currentItemsCount
			}
		}
	}
    
    private func enqueue() {
        // Create inactive views to create the equeuing (.none -> .enqueued) animation effect
        let index = items.firstIndex { item in
            item.state == .none
        }
        
        if let index = index {
            items[index].state = .enqueued
        }
    }
    
    private func dequeue() {
        let index = items.firstIndex { item in
            item.state == .enqueued
        }
        
        if let index = index {
            items[index].state = .dequeued
        }
    }
}
