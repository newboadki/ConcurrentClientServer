//
//  LoadBalancer.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 17.11.2021..
//

import Foundation

protocol LoadBalancer: Sendable {    
    var serviceList: [Service] { get }
    func handle(request: ServiceRequest)
    func cancel()
}
