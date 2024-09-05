//
//  FilterButton.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 27/05/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct FilterButton: View {
    
    var label: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "multiply")
                .accentColor(.lightgrayInverted)
                .frame(width: 30, height: 30, alignment: .center)
            
            Text(label).font(.system(size: 14))
        }
        .padding(.horizontal, 8)
        .background(Color.lightgray)
        .clipShape(Capsule())
        
    }
}

#Preview {
    FilterButton(label: "Haute-Garonne")
}
