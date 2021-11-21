//
//  GCDService.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import Foundation

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