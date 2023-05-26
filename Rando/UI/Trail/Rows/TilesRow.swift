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
                Feedback.selected()
                TaskManager.shared.downloadTilesTask = Task(priority: .background) {
                    do {
                        try await tileManager.download(trail: trail, layer: selectedLayer)
                    } catch {
                        print("􀌓 Download cancelled")
                    }
                }
            } else {
                print("􀌓 User cancelled download")
                TaskManager.shared.downloadTilesTask?.cancel()
                tileManager.state = .idle
                trail.downloadState = .notDownloaded
            }
        }) {
            HStack(spacing: 15) {
                if tileManager.state.isDownloadingAnotherTrail(id: trail.id) {
                    Image(systemName: "xmark.icloud")
                    Text("OtherDownloadInProcess".localized)
                } else {
                    switch trail.downloadState {
                    case .unknown :
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Loading".localized)
                            .foregroundColor(.gray)
                    case .notDownloaded:
                        Image(systemName: "icloud.and.arrow.down")
                        Text("\("Download".localized) (\(tileManager.sizeLeft))")
                            .font(.headline)
                    case .downloading:
                        ProgressView(value: tileManager.progress)
                            .progressViewStyle(CircularProgressViewStyle(tint: .tintColorTabBar))
                        VStack(alignment: .leading) {
                            Text("\("Downloading".localized) (\(tileManager.sizeLeft) \("Left".localized))")
                                .font(.headline)
                            ProgressView(value: tileManager.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .tintColorTabBar))
                                .frame(height: 10)
                        }
                        Image(systemName: "xmark.circle").foregroundColor(.red)
                    case .downloaded:
                        Image(systemName: "checkmark.icloud")
                        Text("Downloaded".localized)
                    }
                }
            }
        }
        .buttonStyle(MyButtonStyle())
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
                .foregroundColor(isEnabled ? .tintColorTabBar : .grgreen)
            // make the button a bit more translucent when pressed
                .opacity(configuration.isPressed ? 0.8 : 1.0)
            // make the button a bit smaller when pressed
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        }
    }
}
