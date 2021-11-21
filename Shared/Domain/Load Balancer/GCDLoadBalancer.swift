//
//  LoadBalancer.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 17.11.2021..
//

import Foundation

class GCDLoadBalancer {
    
    enum RequestError: Error {
        case unsupported
        case serviceUnavailable
    }
    
    var serviceList: [GCDService]
    
    /// Determining the current load must be a synchronous operation since two concurrent calls will not know about
    /// eachother and might decide to overload the same service, when the best solution could have been to distribute the requests.
    private let requestsSerialQueue = DispatchQueue(label: "serial.determine.service.handler")
    private(set) var services: [ServiceRequest.RequestType : [GCDService]]
    private var enqueuedNumberOfRequests: Int = 0
        
    init() {
        let A1 = GCDService(id: "A1", supportedRequestTypes: [.A], delay: 2)
        let A2 = GCDService(id: "A2", supportedRequestTypes: [.A], delay: 5)
        let B = GCDService(id: "B", supportedRequestTypes: [.B], delay: 1)
        let C = GCDService(id: "C", supportedRequestTypes: [.C], delay: 2)
                                
        services = [.A : [A1, A2],
                    .B : [B],
                    .C : [C]]
        
        serviceList = [A1, A2, B, C]
    }
    
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
    
    func firstService(forRequestType type: ServiceRequest.RequestType) -> GCDService {
        return services[type]!.first!
    }
    
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
