//
//  CustomPathView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 5/25/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CustomPathView: View {
    
    @ObservedObject var trail: Trail
    
    var colors: [[Color]] = [
        [.grblue, .grgreen, .red],
        [.orange, .black, .white],
        [.purple, .gray, .yellow],
        [.green, .blue, .cyan],
        [.brown, .indigo, .pink]
    ]
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 32) {
            
            PathPreview(color: trail.color, lineWidth: trail.lineWidth).padding(.top).padding(.top)
            Label("Thickness".localized, systemImage: "paintbrush")
            Slider(value: $trail.lineWidth, in: 3...10, onEditingChanged: { _ in
                TrailManager.shared.save(trail: trail)
            })
            .tint(trail.colorForSlider)
            .frame(width: 200)
            Label("Color".localized, systemImage: "paintpalette")
            Button(action: {
                Feedback.selected()
            }) {
                GridStack(rows: 5, columns: 3) { row, column in
                    Button(action: {
                        trail.color = colors[row][column]
                        TrailManager.shared.save(trail: trail)
                    }) {
                        Circle()
                            .foregroundColor(colors[row][column])
                            .shadow(color: .gray, radius: 5, x: 3, y: 2)
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitle(Text("CustomPath".localized))
    }
}

// MARK: Previews
struct ColorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CustomPathView(trail: Trail())
            .environment(\.colorScheme, .light)
    }
}
