//
//  ServiceRequest.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import Foundation

struct ServiceRequest {
    
    enum RequestType: Hashable {
        case A, B, C
    }
    
    let type: RequestType
    let id: String
    
    init(type: RequestType, id: String = "") {
        self.type = type
        self.id = id
        
    }
}
