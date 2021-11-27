//
//  QueueContainerView.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 20.11.2021..
//

import SwiftUI

struct QueueContainerView: View {
    
    @ObservedObject var presenter: QueuesContainerPresenter
    
    var body: some View {
        VStack {
            
            // Queues
            ForEach(presenter.queueViewModels) { queueViewModel in
                QueueViewComponents(queuePresenter: queueViewModel.presenter, baseColor: queueViewModel.baseColor)
            }

            // Buttons
            HStack(spacing: 50) {
                buttonToCreateReuqestsOfTypeA()
                buttonToCreateReuqestsOfTypeB()
                buttonToCreateReuqestsOfTypeC()
                buttonToCancel()
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
                Text("REQUEST TYPE")
                Image(systemName: "square")
            }
            .font(.system(size: 25))
            .foregroundColor(Color.CyberRetro.pink())
        }
    }
    
    func buttonToCreateReuqestsOfTypeB() -> some View {
        Button {
            presenter.startB()
        } label: {
            HStack {
                Text("REQUEST TYPE")
                Image(systemName: "triangle")
            }
            .font(.system(size: 25))
            .foregroundColor(Color.CyberRetro.blue())
        }
    }
    
    func buttonToCreateReuqestsOfTypeC() -> some View {
        Button {
            presenter.startC()
        } label: {
            HStack {
                Text("REQUEST TYPE")
                Image(systemName: "circle")
            }
            .font(.system(size: 25))
            .foregroundColor(Color.CyberRetro.green())
        }
    }

    func buttonToCancel() -> some View {
        Button {
            presenter.cancel()
        } label: {
            HStack {
                Text("Cancel")
            }
            .font(.system(size: 25))
            .foregroundColor(.blue)
        }
    }
}

struct QueueContainerView_Previews: PreviewProvider {
    static var previews: some View {
        QueueContainerView(presenter: QueuesContainerPresenter(basePresenter: SyncQueuesContainerPresenter(balancer: CurrentMinLoadBalancer(services: baseGCDServiceConfiguration()))))
    }
}
