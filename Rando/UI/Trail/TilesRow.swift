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
    
    var boundingBox: MKMapRect
    
    var body: some View {
        
        Button(action: {
            guard self.tileManager.getSize(for: self.boundingBox) != 0 else { return }
            Feedback.selected()
            self.tileManager.download(boundingBox: self.boundingBox)
        }) {
            HStack(spacing: 15) {
                Image(systemName: "map")
                VStack(alignment: .leading) {
                    if tileManager.status == .download {
                        Text("\("Download".localized) (\(tileManager.getSize(for: boundingBox).toBytes))")
                            .font(.headline)
                    } else if tileManager.status == .downloading {
                        Text("Downloading".localized)
                        .font(.headline)
                    } else {
                        Text("Downloaded".localized)
                        .font(.headline)
                    }
                    ProgressBar(value: $tileManager.progress)
                        .frame(height: 10)
                        .isHidden(tileManager.status == .downloaded, remove: true)
                }
            }
        }
        .onAppear {
            self.tileManager.status = self.tileManager.getSize(for: self.boundingBox) == 0 ? .downloaded : .download
            
        }
    }
}

// MARK: Previews
struct TilesRow_Previews: PreviewProvider {
        
    static var previews: some View {
        
        TilesRow(boundingBox: MKMapRect())
            .previewLayout(.fixed(width: 300, height: 80))
            .environment(\.colorScheme, .light)
    }
}
