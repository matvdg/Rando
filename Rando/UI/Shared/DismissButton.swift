//
//  DismissButton.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 15/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct DismissButton: View {
    var body: some View {
        Image(systemName: "multiply")
            .accentColor(.lightgrayInverted)
        .frame(width: 30, height: 30, alignment: .center)
        .background(Color.lightgray)
        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
        
    }
}

struct DismissButton_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
          DismissButton()
            .environment(\.colorScheme, .light)
          DismissButton()
            .environment(\.colorScheme, .dark)
        }
        .previewLayout(.fixed(width: 100, height: 100))
        
    }
}

