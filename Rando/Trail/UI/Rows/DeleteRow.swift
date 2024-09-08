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
            Label("deleteTrail", systemImage: "trash")
            .accentColor(.red)
        }
        
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("deleteTrailMessage"),
                buttons: [
                    .destructive(Text("deleteTrail"), action: {
                        self.trailManager.remove(id: self.trail.id)
                        dismiss()
                    }),
                    .cancel(Text("cancel"))
                ]
            )
        }
    }
}

// MARK: Preview
#Preview {
    DeleteRow(trail: Trail())
}
