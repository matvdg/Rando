//
//  TrailMapView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/07/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct TrailMapView: View {
    
    var trail: Trail
    @Binding var selectedLayer: Layer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            OldMapView(trail: trail, selectedLayer: $selectedLayer)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack(alignment: .top, spacing: 8) {
                    Button {
                        Feedback.selected()
                        dismiss()
                        
                    } label: {
                        BackIconButton()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }.navigationBarHidden(true)
    }
}

struct TrailMapView_Previews: PreviewProvider {
    
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        TrailMapView(trail: Trail(), selectedLayer: $selectedLayer)
    }
}
