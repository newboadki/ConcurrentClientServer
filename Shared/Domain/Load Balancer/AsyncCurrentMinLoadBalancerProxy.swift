//
//  AyncCurrentMinLoadBalancer.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 25.11.2021..
//

import Foundation


@globalActor
struct LoadBalancerActor {
    
  actor SharedLoadBalancerActor { }

  static let shared: SharedLoadBalancerActor = SharedLoadBalancerActor()
}


/// - Determining the current load must be a synchronous operation since two concurrent calls will not know about
/// each other and might decide to overload the same service, when the best solution might have been to distribute the requests.
///
/// - The service runs in the @LoadBalancerActor global actor. This is so that any load balaning decisions are made synchronously.
/// In particular, this means accessing the service's task load synchronously.
@LoadBalancerActor
class AsyncCurrentMinLoadBalancerProxy {
    
    // MARK: Public properties & types
    
    enum RequestError: Error {
        case unsupported
        case serviceUnavailable
    }
    
    let serviceList: [SwiftCService]
    
    
    // MARK: Private properties
    
    private(set) var services: [ServiceRequest.RequestType : [SwiftCService]]
    
    
    // MARK: Initializers
    
    nonisolated init(services: [ServiceRequest.RequestType : [SwiftCService]]) {
        self.services = services
        self.serviceList = services.flatMap({ (key, value) in
            return value
        })
    }
    
    
    // MARK: Public API
        
    /// This method runs completely synchronously
    func process(request: ServiceRequest) {
        do {
            /// The service runs in the @LoadBalancerActor global actor.
			/// This is so that any load balaning decisions are made synchronously.
            /// In particular, this means accessing the service's task load synchronously.
            let service = try self.service(for: request)
			print("SERVICE: \(service.id)")
            service.process(request: request)
        } catch {
            print(error)
        }
    }

    func cancel() {
        for service in serviceList {
            service.cancel()
        }
    }
    
    // MARK: Load balancing calculation
    
    private func service(for request: ServiceRequest) throws ->  SwiftCService {
                
        guard let supportingServices = services[request.type] else {
            throw RequestError.unsupported
        }
        
        guard supportingServices.count > 0 else {
            throw RequestError.serviceUnavailable
        }

        let service: SwiftCService? = supportingServices.min(by: {
			$0.workLoad() <= $1.workLoad()
		})
        
        guard let service else {
            throw RequestError.serviceUnavailable
        }
        return service
    }
}
