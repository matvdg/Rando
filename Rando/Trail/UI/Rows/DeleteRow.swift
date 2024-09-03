//
//  DeleteRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 5/08/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct DeleteRow: View {
    
    @State private var showAlert = false
    
    private let tileManager = TileManager.shared
    private let trailManager = TrailManager.shared
    private var boundingBox: MKMapRect { trail.polyline.boundingMapRect }
    
    @Environment(\.dismiss) private var dismiss
    
    var trail: Trail
    
    var body: some View {
        
        Button(action: {
            Feedback.selected()
            self.showAlert.toggle()
        }) {
            Label("DeleteTrail", systemImage: "trash")
            .accentColor(.red)
        }
        
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("DeleteTrailMessage"),
                buttons: [
                    .destructive(Text("DeleteTrail"), action: {
                        self.trailManager.remove(id: self.trail.id)
                        dismiss()
                    }),
                    .cancel(Text("Cancel"))
                ]
            )
        }
    }
}

// MARK: Previews
struct DeleteRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DeleteRow(trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
