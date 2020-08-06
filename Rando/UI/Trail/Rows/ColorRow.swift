//
//  ColorRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 6/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct ColorRow: View {
    
    var trail: Trail
    
    var body: some View {
        
        NavigationLink(destination: ColorView(trail: trail)) {
            HStack(spacing: 10) {
                Image(systemName: "eyedropper")
                Text("Color".localized)
                    .font(.headline)
            }
        }.accentColor(.tintColor)
        
    }
}

// MARK: Previews
struct ColorRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ColorRow(trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
