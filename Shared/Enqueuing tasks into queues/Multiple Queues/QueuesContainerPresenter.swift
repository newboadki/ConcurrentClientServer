//
//  QueuesContainerPresenter.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 27.11.2021..
//

import Foundation
import Combine


@MainActor
/// This class wraps concrete implementations of presenters conforming to QueuesContainerPresenterProtocol.
/// It is required because we want the presenters to be ObservableObject. However, making a protocol inherit from ObservableObject required
/// solving a lot of Swift generic quirks. Instead I wrap the presenters into this class and make it conform to ObservableObject.
class QueuesContainerPresenter: QueuesContainerPresenterProtocol, ObservableObject {

	@Published var queueViewModels: [QueueViewModel]

	var queueViewModelsPublisher: Published<[QueueViewModel]>.Publisher {
		return basePresenter.queueViewModelsPublisher
	}

	private var basePresenter: QueuesContainerPresenterProtocol
	private var subscription: AnyCancellable?

	init(basePresenter: QueuesContainerPresenterProtocol) {
		self.basePresenter = basePresenter
		self.queueViewModels = []
		self.subscribe()
	}

	func setup() async {
		await basePresenter.setup()
	}

	func startA() {
		basePresenter.startA()
	}

	func startB() {
		basePresenter.startB()
	}

	func startC() {
		basePresenter.startC()
	}

	func cancel() {
		basePresenter.cancel()
	}

	func subscribe() {
		subscription = queueViewModelsPublisher
			.receive(on: RunLoop.main)
			.assign(to: \.queueViewModels, on: self)
	}
}
