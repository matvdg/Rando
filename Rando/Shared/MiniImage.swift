//
//  MiniImage.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct MiniImage: View {
    
    let poi: Poi
    @State var image: Image?
    
    var body: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70, alignment: .center)
                .clipShape(Circle())
        } else if let image = poi.image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70, alignment: .center)
                .clipShape(Circle())
        } else {
            poi.category.icon
                .resizable()
                .foregroundColor(.white)
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
                .frame(width: 70, height: 70, alignment: .center)
                .background(Color.random.opacity(0.5))
                .clipShape(Circle())
                .onAppear {
                    Task {
                        do {
                            image = try await poi.loadImageFromURL()
                        } catch {
                            print(error)
                        }
                    }
                    
                }
        }
        
    }
    
}

// MARK: Preview
#Preview {
    HStack(alignment: .center, spacing: 20) {
        VStack(alignment: .center, spacing: 20) {
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
        }
        VStack(alignment: .center, spacing: 20) {
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
        }
        VStack(alignment: .center, spacing: 20) {
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
        }
        VStack(alignment: .center, spacing: 20) {
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
        }
    }
}
