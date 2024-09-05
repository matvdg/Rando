//
//  AppIcon.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/06/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct AppIcon: View {
    
    var body: some View {
        Image("icon")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.gray.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

// MARK: Preview
#Preview {
    AppIcon()
}
