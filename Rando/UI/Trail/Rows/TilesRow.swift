//
//  TilesRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct TilesRow: View {
    
    @ObservedObject var tileManager = TileManager.shared
    
    var trail: Trail
    
    var body: some View {
        
        Button(action: {
            if self.tileManager.status == .idle {
                Feedback.selected()
                Task {
                    await self.tileManager.download(trail: trail)
                }
            }
        }) {
            HStack(spacing: 15) {
                let hasBeenDownloaded = self.tileManager.hasBeenDownloaded(for: trail.boundingBox)
                if hasBeenDownloaded { // Downloaded
                    Image(systemName: "checkmark.icloud")
                    Text("Downloaded".localized)
                } else if tileManager.status == .downloading(id: trail.id) { // Downloading
                    ProgressView(value: tileManager.progress)
                        .progressViewStyle(CircularProgressViewStyle(tint: .grgreen))
                    VStack(alignment: .leading) {
                        Text("\("Downloading".localized) (\(tileManager.getEstimatedDownloadSize(for: trail.boundingBox).toBytes) \("Left".localized))")
                            .font(.headline)
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .grgreen))
                            .frame(height: 10)
                    }
                } else if tileManager.status == .idle { // Download
                    Image(systemName: "icloud.and.arrow.down")
                    Text("\("Download".localized) (\(tileManager.getEstimatedDownloadSize(for: trail.boundingBox).toBytes))")
                        .font(.headline)
                } else { // Other downloading in progress
                    Image(systemName: "xmark.icloud")
                    Text("OtherDownloadInProcess".localized)
                }
            }
        }
        .buttonStyle(MyButtonStyle())
        .disabled(!(self.tileManager.status == .idle) || self.tileManager.hasBeenDownloaded(for: trail.boundingBox))
    }
}

// MARK: Previews
struct TilesRow_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TilesRow(trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}

struct MyButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        MyButtonStyleView(configuration: configuration)
    }
    
    struct MyButtonStyleView: View {
        // tracks if the button is enabled or not
        @Environment(\.isEnabled) var isEnabled
        // tracks the pressed state
        let configuration: MyButtonStyle.Configuration
        
        var body: some View {
            return configuration.label
            // change the text color based on if it's disabled
                .foregroundColor(isEnabled ? .tintColor : .grgreen)
            // make the button a bit more translucent when pressed
                .opacity(configuration.isPressed ? 0.8 : 1.0)
            // make the button a bit smaller when pressed
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        }
    }
}
