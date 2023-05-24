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
    
    var trail: Trail
    @StateObject private var taskManager = TaskManager.shared
    
    var body: some View {
        
        Button(action: { // Action only when enabled
            if self.tileManager.state == .idle { // Download (can't be downloaded because the button is disabled in that case)
                Feedback.selected()
                taskManager.task = Task(priority: .background) {
                    do {
                        try await tileManager.download(trail: trail, layer: selectedLayer)
                    } catch {
                        print("􀌓 Download cancelled")
                    }
                }
            } else { // Downloading (can't be downloading other trail because the button is disabled in that case)
                print("􀌓 User cancelled download")
                taskManager.task?.cancel()
                tileManager.state = .idle
            }
        }) {
            HStack(spacing: 15) {
                let hasBeenDownloaded = tileManager.hasBeenDownloaded(for: trail.boundingBox, layer: selectedLayer)
                if hasBeenDownloaded { // Downloaded
                    Image(systemName: "checkmark.icloud")
                    Text("Downloaded".localized)
                } else if tileManager.state == .downloading(id: trail.id) { // Downloading
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
                } else if tileManager.state == .idle { // Download
                    Image(systemName: "icloud.and.arrow.down")
                    Text("\("Download".localized) (\(tileManager.getEstimatedDownloadSize(for: trail.boundingBox, layer: selectedLayer)))")
                        .font(.headline)
                } else { // Other downloading in progress
                    Image(systemName: "xmark.icloud")
                    Text("OtherDownloadInProcess".localized)
                }
            }
        }
        .buttonStyle(MyButtonStyle())
        .disabled( // enabled when download or downloading
            // disabled when other download in progress
            tileManager.state.isDownloadingButAnotherTrail(id2: trail.id)
            // and disabled when downloaded
            || tileManager.hasBeenDownloaded(for: trail.boundingBox, layer: selectedLayer)
        )
    }
}

// MARK: Previews
struct TilesRow_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    static var previews: some View {
        
        TilesRow(selectedLayer: $selectedLayer, trail: Trail())
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
