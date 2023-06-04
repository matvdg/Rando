//
//  CustomPathRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 5/25/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CustomPathRow: View {
    
    @ObservedObject var trail: Trail
    
    var body: some View {
        
        NavigationLink(destination: CustomPathView(trail: trail)) {
            HStack(spacing: 10) {
                Image(systemName: "eyedropper")
                Text("CustomPath")
                    .font(.headline)
            }
        }.accentColor(.tintColorTabBar)
        
    }
}

// MARK: Previews
struct ColorRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CustomPathRow(trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
