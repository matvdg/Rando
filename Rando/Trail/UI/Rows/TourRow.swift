//
//  TourRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 6/08/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TourRow: View {
    
    @ObservedObject var trail: Trail
    
    var body: some View {
        NavigationLink(destination: TourView(trail: trail)) {
            Label("3D", systemImage: "view.3d")
        }.accentColor(.primary)
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
