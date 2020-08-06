//
//  ColorView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 6/08/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct ColorView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var trail: Trail
    
    var colors: [[Color]] = [[.grblue, .grgreen, .red],[.pink, .black, .white],[.purple, .gray, .yellow]]
    
    var body: some View {
        
        Button(action: {
            Feedback.selected()
        }) {
            GridStack(rows: 3, columns: 3) { row, column in
                Button(action: {
                    self.trail.color = self.colors[row][column]
                    TrailManager.shared.save(trail: self.trail)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Circle()
                    .foregroundColor(self.colors[row][column])
                        .shadow(color: .text, radius: 1, x: 0, y: 1)
                }
            }
        .padding(20)
        }
        .navigationBarTitle(Text("Color".localized))
    }
}

// MARK: Previews
struct ColorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ColorView(trail: Trail())
            .environment(\.colorScheme, .light)
    }
}
