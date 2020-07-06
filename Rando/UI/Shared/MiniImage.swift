//
//  CircleImage.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct MiniImage: View {
  
  let id: Int
  
  var body: some View {
    Image(String(id))
      .resizable()
      .background(Color.white)
      .frame(width: 70, height: 70, alignment: .center)
      .clipShape(Circle())
      .shadow(radius: 4)
  }
}

// MARK: Previews
struct MiniImage_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MiniImage(id: 3)
      MiniImage(id: 7)
    }
    .previewLayout(.fixed(width: 100, height: 100))
    .environment(\.colorScheme, .light)
  }
}
