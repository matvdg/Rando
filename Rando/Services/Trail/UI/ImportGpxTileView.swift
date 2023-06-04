//
//  ImportGpxTileView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/06/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct ImportGpxTileView: View {
    
    @Binding var trailsToImport: [Trail]
    var trail: Trail
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(trail.name)
                .font(.largeTitle)
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding()
            TrailPreview(color: .white, points: trail.locationsPreview)
                .frame(width: 80, height: 80)
                .background(Color.clear)
            VStack(alignment: .leading, spacing: 8) {
                Label(trail.distance.toString, systemImage: "point.topleft.down.curvedto.point.bottomright.up.fill")
                if trail.hasElevationData {
                    Label(trail.elevationGain.toStringMeters, systemImage: "arrow.up.forward")
                } else {
                    Label("GPXwithoutAlt", systemImage: "exclamationmark.circle")
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                }
                
            }
            .foregroundColor(.white)
            .padding()
            
        }
        .padding(8)
        .frame(width: 200, height: 300, alignment: .center)
        .background(Color.grgreen)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contextMenu {
            Button {
                trailsToImport.removeAll { $0.id == trail.id }
            } label: {
                Label("Delete", systemImage: "trash")
            }

        }
        
    }
}

struct ImportGpxTileView_Previews: PreviewProvider {
    @State static var trailsToImport = [Trail]()
    static var previews: some View {
        ImportGpxTileView(trailsToImport: $trailsToImport, trail: Trail())
    }
}
