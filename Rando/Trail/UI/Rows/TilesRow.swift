//
//  TilesRow.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/07/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

struct TilesRow: View {
    
    @ObservedObject var tileManager = TileManager.shared
    @EnvironmentObject var appManager: AppManager
    @Binding var state: Trail.DownloadState
    
    var trail: Trail
    
    var body: some View {
        
        Button(action: { // Action only when enabled
            if trail.downloadState == .notDownloaded {
                tileManager.download(trail: trail, layer: appManager.selectedLayer)
            } else {
                tileManager.cancelDownload(trail: trail)
            }
        }) {
            HStack(spacing: 15) {
                if tileManager.state.isDownloadingAnotherTrail(id: trail.id) {
                    Label("otherDownloadInProcess", systemImage: "xmark.icloud").lineLimit(1).minimumScaleFactor(0.5)
                } else {
                    switch trail.downloadState {
                    case .unknown :
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("download")
                    case .notDownloaded:
                        Label("\("download".localized) (\(tileManager.sizeLeft))", systemImage: "icloud.and.arrow.down").lineLimit(1).minimumScaleFactor(0.5)
                    case .downloading:
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(CircularProgressViewStyle(tint: .tintColorTabBar))
                        VStack(alignment: .leading) {
                            Text("\("downloading".localized) \(Int(tileManager.progress*100))% (\(tileManager.sizeLeft) \("left".localized))").lineLimit(1).minimumScaleFactor(0.5)
                            ProgressView(value: tileManager.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .tintColorTabBar))
                                .frame(height: 10)
                        }
                        Image(systemName: "xmark.circle").foregroundColor(.red)
                    case .downloaded:
                        Label("downloaded", systemImage: "checkmark.icloud")
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
        .onChange(of: appManager.selectedLayer) { newValue in
            tileManager.load(for: trail, selectedLayer: appManager.selectedLayer)
        }
        .onChange(of: tileManager.state) { newValue in
            tileManager.load(for: trail, selectedLayer: appManager.selectedLayer)
        }
    }
}

// MARK: Preview
#Preview {
    TilesRow(state: .constant(.unknown), trail: Trail())
}
