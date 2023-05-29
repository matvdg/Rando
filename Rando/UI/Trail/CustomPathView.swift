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
    @Environment(\.colorScheme) var colorScheme
    
    var colors: [[Color]] = [
        [.grblue, .grgreen, .red],
        [.orange, .black, .white],
        [.purple, .gray, .yellow],
        [.green, .blue, .cyan],
        [.brown, .indigo, .pink]
    ]
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 32) {
            
            PathPreview(color: trail.colorHandlingLightAndDarkMode, lineWidth: trail.lineWidth).padding(.top).padding(.top)
            Label("Thickness".localized, systemImage: "paintbrush")
            Slider(value: $trail.lineWidth, in: 3...10, onEditingChanged: { _ in
                Feedback.success()
                TrailManager.shared.save(trail: trail)
            })
            .tint(trail.colorHandlingLightAndDarkMode)
            .frame(width: 200)
            Label("Color".localized, systemImage: "paintpalette")
            Button(action: {
                Feedback.selected()
            }) {
                GridStack(rows: 5, columns: 3) { row, column in
                    Button(action: {
                        Feedback.success()
                        trail.color = colors[row][column]
                        TrailManager.shared.save(trail: trail)
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(colors[row][column])
                                .shadow(color: .gray, radius: 10, x: 5, y: 5)
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                                .foregroundColor(trail.checkMarkColorHandlingBlackAndWhite)
                                .isHidden(!(trail.color == colors[row][column]))
                        }
                        
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
