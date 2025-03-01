//
//  SwiftCService.swift
//  ConcurrentClientServer (iOS)
//
//  Created by Borja Arias Drake on 24.11.2021..
//

import Foundation


actor SwiftCService {

    let id: String
    
    let supportedRequestTypes: [ServiceRequest.RequestType]
    
    /// Services that have the same priority won't run concurrently
    let priority: TaskPriority

    /// A way for the service to communicate that its load changed
    var loadInfoSequence: AsyncStream<ServiceLoadInfo>!

    // MARK: Private properties
    
    /// A multiple of this amount is used in the body of a task representing an incoming request.
    private let delay: UInt32

	/// Continuation to emit values via loadInfoSequence
	private var loadInfoContinuation: AsyncStream<ServiceLoadInfo>.Continuation?

	private var state: SerialExecutorState

	private var requests: [AsyncProcedure]

    // MARK: Private Initializers
    
	init(id: String, priority: TaskPriority, supportedRequestTypes: [ServiceRequest.RequestType], delay: UInt32) {
        self.id = id
        self.priority = priority
        self.supportedRequestTypes = supportedRequestTypes
        self.delay = delay
		self.state = .idle
		self.requests = []

		Task { await self.setup() }
    }

	func setContinuation(_ cont: AsyncStream<ServiceLoadInfo>.Continuation, info: ServiceLoadInfo) async {
		loadInfoContinuation = cont
		loadInfoContinuation?.yield(info)
	}

	func setup() async {
		self.loadInfoSequence = AsyncStream { [weak self] cont in
			Task {
				let info = ServiceLoadInfo(serviceId: "NULL", currentItemsCount: 0)
				await self?.setContinuation(cont, info: info)
			}
		}
	}

	// MARK: Public API

	func process(request: ServiceRequest) async {
		self.requests.append(AsyncProcedure(block: { [weak self] in
			try? await Task.sleep(nanoseconds: 1_000_000_000 * UInt64(self?.delay ?? 0))
		   }))

		loadInfoContinuation?.yield(ServiceLoadInfo(serviceId: self.id, currentItemsCount: requests.count))

		switch state {
			case .idle: break
			case .running: return
		}

		await executeNextRequest()
	}

	private func executeNextRequest() async {
		guard let request = self.requests.first else {
			return
		}

		let task = Task { await request.block() }
		state = .running(task)
		_ = await task.result
		state = .idle

		if !requests.isEmpty {
			requests.remove(at: 0)
			loadInfoContinuation?.yield(ServiceLoadInfo(serviceId: self.id, currentItemsCount: requests.count))
			await executeNextRequest()
		}
	}

	func workLoad() -> Int {
		requests.count
    }
    
	func cancel() async {
		switch state {
			case .running(let task):
				task.cancel()
			default: break
		}

		self.requests.removeAll()
		loadInfoContinuation?.yield(ServiceLoadInfo(serviceId: self.id, currentItemsCount: requests.count))
	}
}
