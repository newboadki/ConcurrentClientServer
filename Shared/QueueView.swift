//
//  Queue_v2.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 20.11.2021..
//

import SwiftUI
import Combine

let itemWidth: CGFloat = 30

struct QueueItemViewModel: Identifiable, Equatable {
    let id: String
    var state: QueueItemState
    var opacity: CGFloat = 1
}

enum QueueItemState {
    case none, enqueued, dequeued
}

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
                        .transition(.opacity)
                }
            }
        }
    }
}

struct QueueView: View {
    
    let items: [QueueItemViewModel]
    let animationsNameSpace: Namespace.ID
    
    var body: some View {
        HStack() {
            HStack {
                ForEach(items) { item in
                    if item.state == .enqueued {
                        QueueItemView(id: item.id, color: .yellow, animationsNameSpace: animationsNameSpace)
                    }
                }
            }
            Spacer()
            
        }
        .padding()
        .frame(width: 800, height: itemWidth + 20)
        .border(Color.blue, width: 4)
    }
}

struct QueueViewComponents: View {
    
    @Namespace private var ns
    @ObservedObject var queuePresenter: QueuePresenter
    
    var body: some View {
        VStack {
            // Queue
            HStack() {
                NotInQueueItemsContainer(items: queuePresenter.items, type: .dequeued, animationsNameSpace: ns)
                    .frame(width: itemWidth, height: itemWidth)
                
                QueueView(items: queuePresenter.items, animationsNameSpace: ns)
                
                NotInQueueItemsContainer(items: queuePresenter.items, type: .none, animationsNameSpace: ns)
            }
            .animation(.easeIn(duration: 0.6), value: queuePresenter.items)
            .padding(50)
            .frame(width: 1000)
        }
        .padding(20)
    }
}

//struct Queue_v2_Previews: PreviewProvider {
//    static var previews: some View {
//        Queue_v2()
//            .previewInterfaceOrientation(.landscapeLeft)
//    }
//}
