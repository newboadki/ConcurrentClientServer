//
//  LoadBalancer.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 17.11.2021..
//

import Foundation


struct ServiceRequest {
    
    enum RequestType: Hashable {
        case A, B, C
    }
    
    let type: RequestType
}

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


class GCDService {
    
    struct LoadInfo {
        let serviceId: String
        let currentItemsCount: Int
    }
    
    @Published var loadInfo: LoadInfo
    
    let id: String
    let supportedRequestTypes: [ServiceRequest.RequestType]
    private let tasksSerialQueue: DispatchQueue
    private let delay: UInt32
        
    /// Queue to serialize access to the work load: the number of tasks currently enqueued in 'tasksSerialQueue'
    private let workLoadSerialQueue: DispatchQueue
        
    /// To only be acccessed through its isolation queue
    /// Underscore notation here means queue member access, it's already synchronized.
    /// From inside a given member queue, you should only accecss properties prefixed with '_' to avoid dead locks.
    private var _workLoad: Int = 0
    
    init(id: String, supportedRequestTypes: [ServiceRequest.RequestType], delay: UInt32) {
        self.id = id
        self.tasksSerialQueue = DispatchQueue(label: "serial.service.\(id).tasks")
        self.workLoadSerialQueue = DispatchQueue(label: "serial.service.\(id).workload")
        self.supportedRequestTypes = supportedRequestTypes
        self.delay = delay
        self.loadInfo = LoadInfo(serviceId: id, currentItemsCount: 0)
    }
    
    func process(request: ServiceRequest) {
        enqueue {
            sleep(self.delay)            
        }
    }
    
    // MARK: Public API
    
    func workLoad() -> Int {
        return workLoadSerialQueue.sync {
            return _workLoad
        }
    }
    
    func enqueue(_ block: @escaping () -> Void) {
        // NOTE: increment and decrement can witherbe async or sync to be dispatched sync because serial execution of inc/dec operations are guaranteed.
        
        // Alternative 1
        self.incrementWorkLoad()
        //print("SERVICE-\(self.id): LOAD: \(self.workLoad())")
        
        // Alertnative 2
        // OSAtomicIncrement64(&_workLoad);

        // Alternative 3
        // Use an NSLock
        
        self.tasksSerialQueue.async {
            //print("SERVICE-\(self.id): about to process request. LOAD: \(self._workLoad)")
            block()
            
            // Alternative 1
            self.decrementWorkLoad()
            //print("SERVICE-\(self.id): finished processing request. LOAD: \(self._workLoad)")
            
            // Alertnative 2
            // OSAtomicDecrement64(&_workLoad);
            
            // Alternative 3
            // Use an NSLock
        }
                
    }
    
    // MARK: Serialization of workLoad access
    private func incrementWorkLoad() {
        workLoadSerialQueue.async {
            self._workLoad += 1
            self.loadInfo = LoadInfo(serviceId: self.id, currentItemsCount: self._workLoad)
            print("SERVICE-\(self.id): LOAD: \(self._workLoad)")
        }
    }

    private func decrementWorkLoad() {
        workLoadSerialQueue.async {
            self._workLoad -= 1
            self.loadInfo = LoadInfo(serviceId: self.id, currentItemsCount: self._workLoad)
            print("SERVICE-\(self.id): LOAD: \(self._workLoad)")
        }
    }
    
    private func resetWorkLoad() {
        workLoadSerialQueue.async {
            self._workLoad = 0
        }
    }
}
