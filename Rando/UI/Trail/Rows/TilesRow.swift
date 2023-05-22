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
    @State var otherDownloadInProgress = false
    
    var boundingBox: MKMapRect
    var name: String
    
    
    var body: some View {
        
        Button(action: {
            if self.tileManager.status == .download {
                Feedback.selected()
                self.tileManager.download(boundingBox: self.boundingBox, name: self.name, layer: currentLayer ?? .ign25)
            }
        }) {
            HStack(spacing: 15) {
                if tileManager.status == .downloaded {
                    Image(systemName: "checkmark")
                    .accentColor(.green)
                } else {
                    Image(systemName: "map")
                }
                VStack(alignment: .leading) {
                    if tileManager.status == .download {
                        Text("\("Download".localized) (\(tileManager.getEstimatedDownloadSize(for: boundingBox, layer: currentLayer ?? .ign25).toBytes))")
                            .font(.headline)
                    } else if tileManager.status == .downloading {
                        Text("\("Downloading".localized) (\(tileManager.getEstimatedDownloadSize(for: boundingBox, layer: currentLayer ?? .ign25).toBytes) \("Left".localized))")
                        .font(.headline)
                    } else {
                        Text("Downloaded".localized)
                    }
                    ProgressView(value: tileManager.progress)
                        .frame(height: 10)
                        .isHidden(tileManager.status != .downloading, remove: true)
                }
            }
            .isHidden(otherDownloadInProgress, remove: true)
        }
        .onAppear {
            guard self.tileManager.status != .downloading else {
                self.otherDownloadInProgress = true
                return
            }
            self.tileManager.status = self.tileManager.hasBeenDownloaded(for: self.boundingBox, layer: currentLayer ?? .ign25) ? .downloaded : .download
        }
    }
}

// MARK: Previews
struct TilesRow_Previews: PreviewProvider {
        
    static var previews: some View {
        
        TilesRow(boundingBox: MKMapRect(), name: "test")
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
