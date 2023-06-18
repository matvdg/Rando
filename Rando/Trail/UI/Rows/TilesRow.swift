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
    @Binding var selectedLayer: Layer
    @Binding var state: Trail.DownloadState
    
    var trail: Trail
    
    var body: some View {
        
        Button(action: { // Action only when enabled
            if trail.downloadState == .notDownloaded {
                tileManager.download(trail: trail, layer: selectedLayer)
            } else {
                tileManager.cancelDownload(trail: trail)
            }
        }) {
            HStack(spacing: 15) {
                if tileManager.state.isDownloadingAnotherTrail(id: trail.id) {
                    Label("OtherDownloadInProcess", systemImage: "xmark.icloud")
                } else {
                    switch trail.downloadState {
                    case .unknown :
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Download")
                    case .notDownloaded:
                        Label("\("Download".localized) (\(tileManager.sizeLeft))", systemImage: "icloud.and.arrow.down")
                    case .downloading:
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(CircularProgressViewStyle(tint: .tintColorTabBar))
                        VStack(alignment: .leading) {
                            Text("\("Downloading".localized) \(Int(tileManager.progress*100))% (\(tileManager.sizeLeft) \("Left".localized))")
                            ProgressView(value: tileManager.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .tintColorTabBar))
                                .frame(height: 10)
                        }
                        Image(systemName: "xmark.circle").foregroundColor(.red)
                    case .downloaded:
                        Label("Downloaded", systemImage: "checkmark.icloud")
                    }
                }
            }
        }
        .tint(.primary)
        .disabled( // enabled when notDownloaded (to download it) or downloading (to cancel it)
            // disabled when other download in progress
            tileManager.state.isDownloadingAnotherTrail(id: trail.id)
            // and disabled when downloaded
            || trail.downloadState == .downloaded
            // and disabled when unkwnow
            || trail.downloadState == .unknown
        )
        .onChange(of: selectedLayer) { newValue in
            tileManager.load(for: trail, selectedLayer: selectedLayer)
        }
        .onChange(of: tileManager.state) { newValue in
            tileManager.load(for: trail, selectedLayer: selectedLayer)
        }
    }
}

// MARK: Previews
struct TilesRow_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    @State static var state: Trail.DownloadState = .unknown
    static var previews: some View {
        
        TilesRow(selectedLayer: $selectedLayer, state: $state, trail: Trail())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
