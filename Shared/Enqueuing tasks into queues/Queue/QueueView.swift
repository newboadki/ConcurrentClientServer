//
//  QueueItemView.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 20.11.2021..
//

import SwiftUI
import Combine

let itemWidth: CGFloat = 15

struct QueueItemView: View {
    
    let id: String
    let color: Color
    let animationsNameSpace: Namespace.ID
    
    var body: some View {
        Rectangle()
            .fill(color)
            .matchedGeometryEffect(id: id, in: animationsNameSpace)
            .frame(width: itemWidth, height: itemWidth)
    }
}

struct NotInQueueItemsContainer: View {
    
    var items: [QueueItemViewModel]
    let type: QueueItemState
    let animationsNameSpace: Namespace.ID
    
    var body: some View {
        ZStack {
            ForEach(items) { item in
                if item.state == type {
                    QueueItemView(id: item.id, color: .yellow, animationsNameSpace: animationsNameSpace)
                        .opacity(type != .enqueued ? 0 : 1)
                        .transition(.opacity)
                }
            }
        }
    }
}

/// This represents the queue itself
struct QueueView: View {
    
    let items: [QueueItemViewModel]
    let animationsNameSpace: Namespace.ID
    let baseColor: Color
    
    var body: some View {
        HStack() {
            HStack {
                ForEach(items) { item in
                    if item.state == .enqueued {
                        QueueItemView(id: item.id, color: baseColor.opacity(0.4), animationsNameSpace: animationsNameSpace)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .frame(width: 800, height: itemWidth + 20)
        .border(baseColor, width: 4)
    }
}

/// In order to animate views in an out of the queue we need three sets of views:
/// - Dequeued Items
/// - Enqueued items (the queue itself)
/// - Items that have never been enqueued
struct QueueViewComponents: View {
    
    @Namespace private var ns
    @ObservedObject var queuePresenter: QueuePresenter
    let baseColor: Color
    
    var body: some View {
        VStack {
            // Queue
            HStack() {
                NotInQueueItemsContainer(items: queuePresenter.items, type: .dequeued, animationsNameSpace: ns)
                    .frame(width: itemWidth, height: itemWidth)
                
                QueueView(items: queuePresenter.items, animationsNameSpace: ns, baseColor: baseColor)
                
                NotInQueueItemsContainer(items: queuePresenter.items, type: .none, animationsNameSpace: ns)
            }
            .animation(.easeIn(duration: 0.6), value: queuePresenter.items)
            .padding(50)
            .frame(width: 1000)
        }
        .padding(20)
    }
}

struct QueueView_Previews: PreviewProvider {
    @Namespace static var ns
    static var previews: some View {
        QueueView(items: [], animationsNameSpace: ns, baseColor: .yellow)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
