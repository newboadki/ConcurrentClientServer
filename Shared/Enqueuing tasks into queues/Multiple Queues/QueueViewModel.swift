//
//  QueueViewModel.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import SwiftUI

struct QueueViewModel: Identifiable {
    
    var id: String {
        presenter.serviceId
    }
    
    let presenter: QueuePresenter
    let baseColor: Color
}
