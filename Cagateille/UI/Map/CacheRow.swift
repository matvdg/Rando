//
//  CacheRow.swift
//  Cagateille
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CacheRow: View {
  
  @State private var showAlert = false
  
  var directory: Directory
      
  var body: some View {
    
    HStack(spacing: 20.0) {
      VStack(alignment: .leading) {
        Text(directory.localized)
          .font(.headline)
        
        HStack {
          Text(TileManager.shared.getSize(of: directory))
        }
        .font(.subheadline)
        
      }
      
      Spacer()
      
      Button(action: {
        self.showAlert = true
        Feedback.selected()
      }) {
        Image(systemName: "trash")
      }
      
    }
    .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    .frame(height: 80.0)
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Delete".localized),
        message: Text(directory.localized),
        primaryButton: .destructive(Text("Delete".localized), action: { TileManager.shared.remove(directory: self.directory) }),
        secondaryButton: .cancel(Text("Cancel".localized)))
      
    }
  }
}

// MARK: Previews
struct CacheRow_Previews: PreviewProvider {
  
  @State static var directory: Directory = .cache
  
  static var previews: some View {
    
    Group {
      CacheRow(directory: directory)
      CacheRow(directory: directory)
    }
    .previewLayout(.fixed(width: 300, height: 80))
    .environment(\.colorScheme, .light)
  }
}
