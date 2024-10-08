//
//  PoiRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PoiRow: View {
    
    @ObservedObject var collectionManager = CollectionManager.shared
    
    var poi: Poi
    
    var body: some View {
        
        HStack(spacing: 20.0) {
            
            MiniImage(poi: poi)
                .frame(width: 70.0, height: 70.0)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(poi.name)
                    .font(.headline)
                    .foregroundColor(.lightgrayInverted)
                
                HStack(spacing: 8) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("altitude")
                            .font(.caption)
                        Text(poi.altitudeInMeters).fontWeight(.bold)
                    }
                }
                .isHidden(poi.altitudeInMeters == "_", remove: true)
                .font(.subheadline)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(.lightgrayInverted)
                
                
            }
            
            Spacer()
            
            Image(systemName: collectionManager.isPoiAlreadyCollected(poi: poi) ? "trophy.fill" : "trophy")
                .foregroundColor(.primary)
            
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .frame(height: 80.0)
    }
    
}

// MARK: Preview
#Preview {
    PoiRow(poi: PoiManager.shared.demoPoi)
}
