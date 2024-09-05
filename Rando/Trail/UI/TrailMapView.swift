//
//  TrailMapView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/07/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailMapView: View {
    
    var trail: Trail
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            MapView(trail: trail)
                .edgesIgnoringSafeArea(.all)
                .edgesIgnoringSafeArea(.all)
        }.navigationTitle(trail.name)
    }
}

#Preview {
    TrailMapView(trail: Trail())
}
