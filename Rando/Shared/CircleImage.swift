//
//  CircleImage.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    
    let poi: Poi
    @State var image: Image?
    
    var body: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
        } else if let image = poi.image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
        } else {
            poi.category.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
                .frame(width: 200, height: 200, alignment: .center)
                .background(Color.random)
                .clipShape(Circle())
                .onAppear {
                    Task {
                        do {
                            image = try await poi.loadImageFromUrl()
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
    Group {
        CircleImage(poi: Poi())
        CircleImage(poi: Poi())
        
    }
}
