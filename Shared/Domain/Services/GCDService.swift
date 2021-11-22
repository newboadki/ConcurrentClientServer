//
//  GCDService.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import Foundation

class GCDService: Service {
    
    // MARK: Public properties
    
    let id: String
    let supportedRequestTypes: [ServiceRequest.RequestType]
    
    var loadInfoPublisher: Published<ServiceLoadInfo>.Publisher {
        $loadInfo
    }
    
    // MARK: Private properties
    
    @Published private var loadInfo: ServiceLoadInfo
    private let tasksSerialQueue: DispatchQueue
    private let delay: UInt32
        
    /// Queue to serialize access to the work load: the number of tasks currently enqueued in 'tasksSerialQueue'
    private let workLoadSerialQueue: DispatchQueue
        
    /// To only be acccessed through its isolation queue
    /// Underscore notation here means queue member access, it's already synchronized.
    /// From inside a given member queue, you should only accecss properties prefixed with '_' to avoid dead locks.
    private var _workLoad: Int = 0
    
    // To allow cancellation of tasks.
    private var workItems: [DispatchWorkItem]
    
    // MARK: Initializers
    
    init(id: String, supportedRequestTypes: [ServiceRequest.RequestType], delay: UInt32) {
        self.id = id
        self.tasksSerialQueue = DispatchQueue(label: "serial.service.\(id).tasks")
        self.workLoadSerialQueue = DispatchQueue(label: "serial.service.\(id).workload")
        self.supportedRequestTypes = supportedRequestTypes
        self.delay = delay
        self.loadInfo = ServiceLoadInfo(serviceId: id, currentItemsCount: 0)
        self.workItems = []
    }
    
    // MARK: Public API
        
    func process(request: ServiceRequest) {
        processDispatchWorkItem(request: request)
    }
    
    func workLoad() -> Int {
        return workLoadSerialQueue.sync {
            return _workLoad
        }
    }

    func cancel() {
        for workItem in workItems { workItem.cancel() }
        workItems.removeAll()
        resetWorkLoad()
    }
    
    // MARK: Enqueuing work
    
    func processWithBlock(request: ServiceRequest) {
        enqueue {
            sleep(self.delay)
        }
    }
    
    private func processDispatchWorkItem(request: ServiceRequest) {
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem {
            sleep(self.delay)
            for i in 1...10_000 {
                if workItem?.isCancelled ?? false {
                    // It does not seem to enter here for all enqueued tasks
                    // However, tasks do stop executing.
                    return
                }
                print("\(self.id)-Working...\(i)")
            }
            sleep(self.delay)
            self.decrementWorkLoad()
        }
        
        guard let wi = workItem else {
            return
        }
        
        self.incrementWorkLoad()
        self.workItems.append(wi)
        self.tasksSerialQueue.async(execute: wi)
    }

    private func enqueue(_ block: @escaping () -> Void) {
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
            self.loadInfo = ServiceLoadInfo(serviceId: self.id, currentItemsCount: self._workLoad)
            print("SERVICE-\(self.id): LOAD: \(self._workLoad)")
        }
    }

    private func decrementWorkLoad() {
        workLoadSerialQueue.async {
            self._workLoad = max (self._workLoad - 1, 0)
            self.loadInfo = ServiceLoadInfo(serviceId: self.id, currentItemsCount: self._workLoad)
            print("SERVICE-\(self.id): LOAD: \(self._workLoad)")
        }
    }
    
    private func resetWorkLoad() {
        workLoadSerialQueue.async {
            self._workLoad = 0
            self.loadInfo = ServiceLoadInfo(serviceId: self.id, currentItemsCount: self._workLoad)
        }
    }
}
