//
//  Service.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import Foundation

protocol Service {
    var id: String { get }
    var supportedRequestTypes: [ServiceRequest.RequestType] { get }
	var loadInfoSequence: AsyncStream<ServiceLoadInfo> { get }
    func process(request: ServiceRequest)
    func workLoad() -> Int
    func cancel()
}

struct ServiceLoadInfo {
    let serviceId: String
    let currentItemsCount: Int
}
