//
//  QueueContainerView.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 20.11.2021..
//

import SwiftUI

struct QueueContainerView: View {
    
    @State private var presenter = QueuesContainerPresenter()
    
    var body: some View {
        VStack {
            
            ForEach(presenter.queueViewModels) { queueViewModel in
                QueueViewComponents(queuePresenter: queueViewModel.presenter)
            }
                        
            VStack(spacing: 50) {
                Button {
                    presenter.pushToService()
                } label: {
                    HStack {
                        Image(systemName: "cross")
                        Text("PUSH WORK")
                    }
                    .font(.system(size: 25))
                }
            }
        }
    }
}

struct QueueContainerView_Previews: PreviewProvider {
    static var previews: some View {
        QueueContainerView()
    }
}
