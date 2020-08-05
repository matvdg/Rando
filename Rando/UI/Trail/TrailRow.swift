//
//  TrailRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailRow: View {
    
    @State var trail: Trail
    
    var body: some View {
        
        HStack {
            
            TrailPreview(points: trail.locationsPreview)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Image(systemName: trail.displayed ? "eye" : "eye.slash")
                        .foregroundColor(trail.displayed ? .tintColor : .lightgray)
                    Text(trail.name)
                        .font(.headline)
                }
                
                
                Text("\(trail.distance.toString) - \(trail.positiveElevation.toStringMeters)")
                .font(.subheadline)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                
            }
            
            Spacer()
            
            Image(systemName: trail.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(.red)
            
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .frame(height: 80.0)
    }
    
}

// MARK: Previews
struct TrailRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TrailRow(trail: Trail())
            .previewLayout(.fixed(width: 320, height: 80))
        
    }
}
