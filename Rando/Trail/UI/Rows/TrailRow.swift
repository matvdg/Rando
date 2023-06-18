//
//  TrailRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailRow: View {
    
    @ObservedObject var trail: Trail
    
    var body: some View {
        
        HStack {
            
            TrailPreview(color: trail.colorHandlingLightAndDarkMode, points: trail.locationsPreview)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Image(systemName: trail.isDisplayed ? "eye" : "eye.slash")
                        .foregroundColor(trail.isDisplayed ? .tintColorTabBar : .lightgray)
                    Text(trail.name)
                        .font(.headline)
                        .foregroundColor(.lightgrayInverted)
                }
                
                if trail.hasElevationData {
                    Text("\(trail.distance.toString) - \(trail.elevationGain.toStringMeters)")
                        .font(.subheadline)
                        .foregroundColor(.lightgrayInverted)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                } else {
                    Text("\(trail.distance.toString)")
                        .font(.subheadline)
                        .foregroundColor(.lightgrayInverted)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: trail.isFav ? "heart.fill" : "heart")
                .foregroundColor(.red)
            
        }
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        .frame(height: 80.0)
        .tint(.tintColorTabBar)
    }
    
}

// MARK: Previews
struct TrailRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TrailRow(trail: Trail())
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 320, height: 80))
        
    }
}
