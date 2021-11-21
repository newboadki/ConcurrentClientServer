//
//  LoadBalancer.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 17.11.2021..
//

import Foundation

class GCDLoadBalancer: LoadBalancer {
    
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
    private(set) var services: [ServiceRequest.RequestType : [GCDService]]
    private var enqueuedNumberOfRequests: Int = 0
        
    // MARK: Initializers
    
    init() {
        let A1 = GCDService(id: "A1", supportedRequestTypes: [.A], delay: 2)
        let A2 = GCDService(id: "A2", supportedRequestTypes: [.A], delay: 5)
        let B = GCDService(id: "B", supportedRequestTypes: [.B], delay: 1)
        let C1 = GCDService(id: "C1", supportedRequestTypes: [.C], delay: 2)
        let C2 = GCDService(id: "C2", supportedRequestTypes: [.C], delay: 1)
        let C3 = GCDService(id: "C3", supportedRequestTypes: [.C], delay: 3)
                                
        services = [.A : [A1, A2],
                    .B : [B],
                    .C : [C1, C2, C3]]
        
        serviceList = [A1, A2, B, C1, C2, C3]
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
    
    // MARK: Helpers
    
    private func service(for request: ServiceRequest) throws ->  GCDService {
                
        guard let supportingServices = services[request.type] else {
            throw RequestError.unsupported
        }
        
        guard supportingServices.count > 0 else {
            throw RequestError.serviceUnavailable
        }
        
        var minWorkLoad: Int = Int.max
        var service: GCDService?
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
