//
//  CacheView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 12/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CacheView: View {
    
  var body: some View {
    
    List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
      CacheRow()
    }
  }
}

// MARK: Previews
struct CacheView_Previews: PreviewProvider {
  static var previews: some View {
    CacheView()
  }
}
