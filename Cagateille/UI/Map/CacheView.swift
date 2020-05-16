//
//  CacheView.swift
//  Cagateille
//
//  Created by Mathieu Vandeginste on 12/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CacheView: View {
  
    
  var body: some View {
    
    List {
      CacheRow(directory: .cagateille)
      CacheRow(directory: .cache)
    }
    .navigationBarTitle(Text("ManageCache".localized))
    
  }
  
}

// MARK: Previews
struct CacheView_Previews: PreviewProvider {
  static var previews: some View {
    CacheView()
  }
}
