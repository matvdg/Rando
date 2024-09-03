//
//  ImportGpxTileView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/06/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct ImportGpxTileView: View {
    
    @Binding var trailsToImport: [Trail]
    var trail: Trail
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Spacer()
                Button {
                    Feedback.failed()
                    trailsToImport.removeAll { $0.id == trail.id }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25, alignment: .center)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 8))
                }
            }
            
            Text(trail.name)
                .font(.largeTitle)
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal, 8)
            Spacer()
            TrailPreview(color: .white, points: trail.locationsPreview)
                .frame(width: 80, height: 80)
                .background(Color.clear)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Label(trail.distance.toString, systemImage: "point.topleft.down.curvedto.point.bottomright.up.fill")
                if trail.hasElevationData {
                    Label(trail.elevationGain.toStringMeters, systemImage: "arrow.up.forward")
                } else {
                    Label("GPXwithoutAlt", systemImage: "exclamationmark.circle")
                        .minimumScaleFactor(0.45)
                }
                
            }
            .foregroundColor(.white)
            
        }
        .padding(8)
        .frame(width: 200, height: 290, alignment: .center)
        .background(LinearGradient(gradient: Gradient(colors: [Color.grblue, Color.grgreen]), startPoint: .top, endPoint: .bottom))
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
        ImportGpxTileView(trailsToImport: $trailsToImport, trail: Trail(gpx: Gpx(name: "Le Crabère", locations: [mockLoc1,mockLoc2], department: "Ariège")))
    }
}
