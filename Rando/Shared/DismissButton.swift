//
//  DismissButton.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/08/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct DismissButton: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.lightgrayInverted)
    }
}

#Preview {
    Group {
      DismissButton()
        .environment(\.colorScheme, .light)
      DismissButton()
        .environment(\.colorScheme, .dark)
    }
}

