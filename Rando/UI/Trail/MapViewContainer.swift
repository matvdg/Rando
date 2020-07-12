//
//  MapViewContainer.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 12/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import CoreLocation


struct MapViewContainer: View {
    
    var trail: Trail
    
    var body: some View {
        MapView(trail: trail)
            .navigationBarTitle(Text("Map".localized))
    }
}

struct MapViewContainer_Previews: PreviewProvider {
    
    @State static var trail = Trail(name: "test", locations: [])
    
    static var previews: some View {
        MapViewContainer(trail: trail)
    }
}
