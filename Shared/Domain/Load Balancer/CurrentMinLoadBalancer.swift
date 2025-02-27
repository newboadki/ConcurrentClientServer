//
//  LoadBalancer.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 17.11.2021..
//

import Foundation

class CurrentMinLoadBalancer: @unchecked Sendable, LoadBalancer {

    // MARK: Public properties & types
    
    enum RequestError: Error {
        case unsupported
        case serviceUnavailable
    }
    
    let serviceList: [Service]
    
    // MARK: Private properties
    
    /// Determining the current load must be a synchronous operation since two concurrent calls will not know about
    /// eachother and might decide to overload the same service, when the best solution could have been to distribute the requests.
    private let requestsSerialQueue = DispatchQueue(label: "serial.determine.service.handler")
    private(set) var services: [ServiceRequest.RequestType : [Service]]
    private var enqueuedNumberOfRequests: Int = 0
        
    // MARK: Initializers
    
    init(services: [ServiceRequest.RequestType : [Service]]) {
        self.services = services
        self.serviceList = services.flatMap({ (key, value) in
            return value
        })
    }
    
    // MARK: Public API
    
    func handle(request: ServiceRequest) {
        requestsSerialQueue.async { [unowned self] in
            do {
                let service = try service(for: request)
                service.process(request: request)
            } catch {
                print(error)
            }
        }
    }
    
    func cancel() {
        for service in serviceList {
            service.cancel()
        }
    }
    
    // MARK: Helpers
    
    private func service(for request: ServiceRequest) throws ->  Service {
                
        guard let supportingServices = services[request.type] else {
            throw RequestError.unsupported
        }
        
        guard supportingServices.count > 0 else {
            throw RequestError.serviceUnavailable
        }
        
        var minWorkLoad: Int = Int.max
        var service: Service?
        for s in supportingServices {
            let currentWorkLoad = s.workLoad()
            if currentWorkLoad < minWorkLoad {
                minWorkLoad = currentWorkLoad
                service = s
            }
        }
        
        guard let finalService = service else {
            throw RequestError.serviceUnavailable
        }
        
        return finalService
    }
}
