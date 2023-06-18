//
//  DisplayRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct DisplayRow: View {
    
    @ObservedObject var trail: Trail
    
    var body: some View {
        
        Button(action: {
            Feedback.selected()
            self.trail.isDisplayed.toggle()
            TrailManager.shared.save(trail: self.trail)
        }) {
            if trail.isDisplayed {
                HStack(spacing: 10) {
                    Image(systemName: "eye.slash")
                    Text("DoNotDisplayOnMap")
                        .font(.headline)
                }
                .accentColor(.red)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "eye")
                    Text("DisplayOnMap")
                        .font(.headline)
                }
            }
        }
    }
}

// MARK: Previews
struct DisplayRow_Previews: PreviewProvider {
        
    static var previews: some View {
        
        DisplayRow(trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
