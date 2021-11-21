//
//  QueueContainerView.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 20.11.2021..
//

import SwiftUI

struct QueueContainerView: View {
    
    let presenter: QueuesContainerPresenter
    
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

}

struct QueueContainerView_Previews: PreviewProvider {
    static var previews: some View {
        QueueContainerView(presenter: QueuesContainerPresenter(balancer: GCDLoadBalancer(services: baseServiceConfiguration())))
    }
}
