//
//  TourView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 04/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI


struct TourView: View {
    
    @State private var animationRotationAmount = 0.0
    @State var clockwise = false
    var trail: Trail
    
    var body: some View {
        
        MapView(clockwise: $clockwise, trail: trail)
            .accentColor(.grblue)
            .navigationBarTitle(Text(trail.name))
            .navigationBarItems(trailing:
                Button(action: {
                    Feedback.selected()
                    self.clockwise.toggle()
                    self.animationRotationAmount += .pi
                }) {
                    Text("direction")
                    Image(systemName: "arrow.2.circlepath")
                        .rotation3DEffect(.radians(animationRotationAmount), axis: (x: 0, y: 0, z: 1))
                        .animation(.default, value: clockwise)
            })
            .onAppear {
                Task {
                    await NetworkManager.shared.runIfNetwork()
                    isPlayingTour = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.clockwise = true
                    }
                }
            }
            .onDisappear {
                isPlayingTour = false
            }
    }
    
}

// MARK: Preview
#Preview {
    TourView(trail: Trail())
}
