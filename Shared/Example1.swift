//
//  Example1.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 18.11.2021..
//

import SwiftUI

struct Example1View: View {
    @Namespace var nspace
    @State private var flag: Bool = true

    var body: some View {
        HStack {
            if flag {
                Rectangle().fill(Color.green)
                    .matchedGeometryEffect(id: "geoeffect1", in: nspace)
                    .frame(width: 100, height: 100)
            }

            Spacer()

            Button("Switch") { withAnimation(.easeInOut(duration: 2.0)) { flag.toggle() } }

            Spacer()

            VStack {
                Rectangle().fill(Color.yellow).frame(width: 50, height: 50)
                
                if !flag {
                    Circle()
                        .fill(Color.blue)
                        .matchedGeometryEffect(id: "geoeffect1", in: nspace)
                        .frame(width: 50, height: 50)
                        .border(Color.black)
                        .zIndex(1)
                }
                
                Rectangle().fill(Color.yellow).frame(width: 50, height: 50)
            }
        }
        .frame(width: 250).padding(10).border(Color.gray, width: 3)
    }
}

struct Example1View_Previews: PreviewProvider {
    static var previews: some View {
        Example1View()
    }
}
