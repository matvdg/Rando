//
//  PictureView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 06/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct PictureView: View {
    
    @State var image: Image
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200, alignment: .center)
            .clipShape(Rectangle())
            .cornerRadius(20)
    }
    
}

// MARK: Preview
#Preview {
    Group {
        PictureView(image: Image("ign"))
        PictureView(image: Image("ign25"))
    }
}
