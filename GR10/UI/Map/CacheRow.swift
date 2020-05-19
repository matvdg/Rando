//
//  CacheRow.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 08/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct CacheRow: View {
  
  @State private var showAlert = false
  @ObservedObject var tileManager = TileManager.shared
  
  var directory: Directory
  
  var body: some View {
    
    HStack {
      
      VStack(alignment: .leading) {
        Text(directory.localized)
          .font(.headline)
        
        HStack {
          if directory.state == .downloaded {
            Text(tileManager.getSize(of: directory))
          } else if directory.state == .downloading {
            Text("Downloading".localized)
          } else {
            Text("Requirements".localized)
          }
          
        }
        .font(.subheadline)
        
        ProgressBar(value: $tileManager.progress)
          .frame(height: 2)
          .isHidden(directory.state != .downloading)
      }
      .frame(width: 220)
      
      Spacer()
      
      Button(action: {
        Feedback.selected()
        switch self.directory.state {
        case .downloaded:
          self.showAlert = true
        case .downloading: return
        case .empty:
          self.tileManager.startDownload()
        }
      }) {
      if self.directory.state == .downloaded {
        Image(systemName: "trash")
      } else if self.directory.state == .downloading {
        EmptyView()
      } else {
        Image(systemName: "square.and.arrow.down.on.square")
      }
    }
    
  }
  .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
  .frame(height: 80.0)
  .alert(isPresented: $showAlert) {
  Alert(
  title: Text("Delete".localized),
  message: Text(directory.localized),
  primaryButton: .destructive(Text("Delete".localized), action: { self.tileManager.remove(directory: self.directory) }),
  secondaryButton: .cancel(Text("Cancel".localized)))
  
  }
}
}

// MARK: Previews
struct CacheRow_Previews: PreviewProvider {
  
  @State static var cache: Directory = .cache
  @State static var gr: Directory = .gr10
  
  static var previews: some View {
    
    Group {
      CacheRow(directory: cache)
      CacheRow(directory: gr)
    }
    .previewLayout(.fixed(width: 300, height: 80))
    .environment(\.colorScheme, .light)
  }
}
