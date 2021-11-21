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
            
            // Queues
            ForEach(presenter.queueViewModels) { queueViewModel in
                QueueViewComponents(queuePresenter: queueViewModel.presenter)
            }

            // Buttons
            HStack(spacing: 50) {
                buttonToCreateReuqestsOfTypeA()
                buttonToCreateReuqestsOfTypeB()
                buttonToCreateReuqestsOfTypeC()
            }
        }
    }
}

private extension QueueContainerView {
    
    func buttonToCreateReuqestsOfTypeA() -> some View {
        Button {
            presenter.startA()
        } label: {
            HStack {
                Image(systemName: "cross")
                Text("REQUEST - A")
            }
            .font(.system(size: 25))
        }
    }
    
    func buttonToCreateReuqestsOfTypeB() -> some View {
        Button {
            presenter.startB()
        } label: {
            HStack {
                Image(systemName: "cross")
                Text("REQUEST - B")
            }
            .font(.system(size: 25))
        }
    }
    
    func buttonToCreateReuqestsOfTypeC() -> some View {
        Button {
            presenter.startC()
        } label: {
            HStack {
                Image(systemName: "cross")
                Text("REQUEST - C")
            }
            .font(.system(size: 25))
        }
    }

}

struct QueueContainerView_Previews: PreviewProvider {
    static var previews: some View {
        QueueContainerView()
    }
}
