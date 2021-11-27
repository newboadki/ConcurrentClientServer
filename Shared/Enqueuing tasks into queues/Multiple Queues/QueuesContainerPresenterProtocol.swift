//
//  QueuesContainerPresenterProtocol.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 25.11.2021..
//

import Foundation
import Combine

@MainActor
protocol QueuesContainerPresenterProtocol {
    
    var queueViewModelsPublisher: Published<[QueueViewModel]>.Publisher { get }
    
    func startA()
    func startB()
    func startC()
    func cancel()
}
