//
//  PoiRow.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CacheRow: View {
      
  var body: some View {
    
    HStack(spacing: 20.0) {
      VStack(alignment: .leading) {
        Text("Cache (autres tuiles)")
          .font(.headline)
        
        HStack {
          Text("300Mo")
        }
        .font(.subheadline)
        
      }
      
      Spacer()
    }
    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    .frame(height: 80.0)
  }
}

// MARK: Previews
struct CacheRow_Previews: PreviewProvider {
  
  static var previews: some View {
    
    Group {
      CacheRow()
      CacheRow()
    }
    .previewLayout(.fixed(width: 300, height: 80))
    .environment(\.colorScheme, .light)
  }
}
