//
//  ItineraryRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 1/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct ItineraryRow: View {
    
    var id: String
    @State private var storedId = UserDefaults.currentTrail
    
    var body: some View {
        
        Button(action: {
            Feedback.selected()
            UserDefaults.currentTrail = UserDefaults.currentTrail == self.id ? "nil" : self.id
            self.storedId = UserDefaults.currentTrail
            TrailManager.shared.getTrails()
        }) {
            if storedId == id {
                HStack(spacing: 10) {
                    Image(systemName: "eye.slash")
                    Text("DoNotDisplayOnMap".localized)
                        .font(.headline)
                }
                .accentColor(.red)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "eye")
                    Text("DisplayOnMap".localized)
                        .font(.headline)
                }
            }
        }
    }
}

// MARK: Previews
struct ItineraryRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DisplayRow(id: "test")
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
