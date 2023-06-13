//
//  TourRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 6/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TourRow: View {
    
    @ObservedObject var trail: Trail
    
    var body: some View {
        
        NavigationLink(destination: TourView(trail: trail)) {
            HStack(spacing: 10) {
                Image(systemName: "view.3d")
                Text("3D")
                    .font(.headline)
            }
        }.accentColor(.tintColorTabBar)
        
    }
}

// MARK: Previews
struct TourRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TourRow(trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
