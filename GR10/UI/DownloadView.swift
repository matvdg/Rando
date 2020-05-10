//
//  DownloadView.swift
//  GR10
//
//  Created by Mathieu Vandeginste on 09/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct DownloadView: View {
  
  @Binding var hideDownloadView: Bool
  @State var progressValue: Float = 0.0
  
  var imageId: Int { Int(progressValue * 20) - 1 }
  
  var body: some View {
    ZStack {
      LinearGradient(gradient: Gradient(colors: [.red, .white]), startPoint: .bottom, endPoint: .top).edgesIgnoringSafeArea(.all)
      VStack(spacing: 30) {
        Spacer()
        Text("Welcome".localized)
          .font(.largeTitle)
          .foregroundColor(.black)
        Spacer()
        CircleImage(id: imageId)
        Spacer()
        Text("Downloading".localized)
          .font(.subheadline)
          .foregroundColor(.black)
        ProgressBar(value: $progressValue)
          .frame(height: 20)
        Text("Requirements".localized)
          .font(.footnote)
          .foregroundColor(.black)
        Spacer()
      }
      .padding()
    }
    .onAppear {
      TileManager.shared.saveTilesAroundPolyline { progress in
        self.progressValue = progress
        if progress == 1 {
          self.hideDownloadView = true
        }
      }
    }
  }
}

struct DownloadView_Previews: PreviewProvider {
  
  @State static var hideDownloadView = false
  static var previews: some View {
    DownloadView(hideDownloadView: $hideDownloadView)
  }
}
