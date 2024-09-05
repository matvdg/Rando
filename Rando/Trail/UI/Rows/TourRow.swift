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
            Label("watchFlyoverTour", systemImage: "view.3d")
        }.accentColor(.primary)
    }
}

// MARK: Preview
#Preview {
    TourRow(trail: Trail())
}
