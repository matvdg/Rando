//
//  CircleImage.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
  
  let id: Int
  
  var body: some View {
    Image(String(id))
      .resizable()
      .background(Color.white)
      .frame(width: 200, height: 200, alignment: .center)
      .clipShape(Circle())
  }
}

// MARK: Previews
struct CircleImage_Previews: PreviewProvider {
  static var previews: some View {
    CircleImage(id: 0)
      .previewDevice(PreviewDevice(rawValue: "iPhone X"))
      .previewDisplayName("iPhone X")
      .environment(\.colorScheme, .dark)
  }
}
