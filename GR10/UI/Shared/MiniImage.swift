//
//  CircleImage.swift
//  GR10
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
      .background(/*@START_MENU_TOKEN@*/Color.green/*@END_MENU_TOKEN@*/)
      .frame(width: 30, height: 30, alignment: .center)
      .clipShape(Circle())
      .overlay(Circle().stroke(Color.white, lineWidth: 2))
      .shadow(radius: 2)
  }
}

struct MiniImage_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MiniImage(id: 99)
      MiniImage(id: 0)
    }
    .previewLayout(.fixed(width: 100, height: 100))
    .environment(\.colorScheme, .light)
  }
}
