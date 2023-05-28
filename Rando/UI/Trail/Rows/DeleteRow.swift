//
//  DeleteRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 5/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct DeleteRow: View {
    
    @State private var showAlert = false
    
    private let tileManager = TileManager.shared
    private let trailManager = TrailManager.shared
    private var boundingBox: MKMapRect { trail.polyline.boundingMapRect }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var trail: Trail
    
    var body: some View {
        
        Button(action: {
            Feedback.selected()
            self.showAlert.toggle()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "trash")
                Text("DeleteTrail".localized)
                    .font(.headline)
            }
            .accentColor(.red)
        }
        
        .actionSheet(isPresented: $showAlert) {
            return ActionSheet(
                title: Text("DeleteTrailMessage".localized),
                buttons: [
                    .destructive(Text("DeleteTrail".localized), action: {
                        self.trailManager.remove(id: self.trail.id)
                        self.presentationMode.wrappedValue.dismiss()
                    }),
                    .cancel(Text("Cancel".localized))
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
