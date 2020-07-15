//
//  DisplayRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct DisplayRow: View {
    
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
                HStack {
                    Image(systemName: "eye.slash")
                    Text("DoNotDisplayOnMap".localized)
                        .font(.headline)
                }
                .accentColor(.red)
            } else {
                Image(systemName: "eye")
                Text("DisplayOnMap".localized)
                    .font(.headline)
            }
        }
    }
}

// MARK: Previews
struct DisplayRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DisplayRow(id: "test")
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
