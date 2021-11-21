//
//  Color+CyberPunkRetroPalette.swift
//  ConcurrentClientServer
//
//  Created by Borja Arias Drake on 21.11.2021..
//

import SwiftUI

extension Color {
    
    struct CyberRetro {
        
        static func pink() -> Color {
            Color(UIColor(named: "CyberPink")!)
        }
        
        static func green() -> Color {
            Color(UIColor(named: "CyberGreen")!)
        }

        static func blue() -> Color {
            Color(UIColor(named: "CyberBlue")!)
        }
    }
}
