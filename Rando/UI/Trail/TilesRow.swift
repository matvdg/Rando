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
    @State private var showAlert = false
    @State var otherDownloadInProgress = false
    
    var boundingBox: MKMapRect
    var name: String
    
    
    var body: some View {
        
        Button(action: {
            if self.tileManager.status == .download {
                Feedback.selected()
                self.tileManager.download(boundingBox: self.boundingBox, name: self.name)
            } else if self.tileManager.status == .downloaded {
                Feedback.selected()
                self.showAlert = true
            }
        }) {
            HStack(spacing: 15) {
                if tileManager.status == .downloaded {
                    Image(systemName: "trash")
                    .accentColor(.red)
                } else {
                    Image(systemName: "map")
                }
                VStack(alignment: .leading) {
                    if tileManager.status == .download {
                        Text("\("Download".localized) (\(tileManager.getEstimatedDownloadSize(for: boundingBox).toBytes))")
                            .font(.headline)
                    } else if tileManager.status == .downloading {
                        Text("\("Downloading".localized) (\(tileManager.getEstimatedDownloadSize(for: boundingBox).toBytes) \("Left".localized))")
                        .font(.headline)
                    } else {
                        Text("\("DeleteTiles".localized) (\(tileManager.getDownloadedSize(for: boundingBox).toBytes))")
                        .font(.headline)
                        .accentColor(.red)
                    }
                    ProgressBar(value: $tileManager.progress)
                        .frame(height: 10)
                        .isHidden(tileManager.status == .downloaded, remove: true)
                }
            }
            .isHidden(otherDownloadInProgress, remove: true)
        }
        .onAppear {
            guard self.tileManager.status != .downloading else {
                self.otherDownloadInProgress = true
                return
            }
            self.tileManager.status = self.tileManager.getEstimatedDownloadSize(for: self.boundingBox) == 0 ? .downloaded : .download
        }
        .actionSheet(isPresented: $showAlert) {
            ActionSheet(
                title: Text("\("Delete".localized) (\(self.tileManager.getDownloadedSize(for: boundingBox).toBytes))"),
                message: Text("DeleteTiles".localized),
                buttons: [
                    .destructive(Text("Delete".localized), action: { self.tileManager.remove(for: self.boundingBox) }),
                    .cancel(Text("Cancel".localized))
                ]
            )
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
