//
//  MiniImage.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
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
            poi.icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.white)
                .frame(width: 70, height: 70, alignment: .center)
                .background(Color.random)
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

// MARK: Previews
struct MiniImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MiniImage(poi: Poi())
            MiniImage(poi: Poi())
            
        }
        .previewLayout(.fixed(width: 100, height: 100))
        .environment(\.colorScheme, .light)
    }
}
