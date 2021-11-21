//
//  File.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import SwiftUI

enum QueueItemState {
    case none, enqueued, dequeued
}

struct QueueItemViewModel: Identifiable, Equatable {
    let id: String
    var state: QueueItemState
    var opacity: CGFloat = 1
}

