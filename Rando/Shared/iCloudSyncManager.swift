//
//  iCloudSyncManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

class iCloudSyncManager {
    
    static let shared: iCloudSyncManager = iCloudSyncManager()
    
    private var metadataQuery: NSMetadataQuery?
    
    func synchronizeAllFilesInBackground() {
        DispatchQueue.main.async {
            self.metadataQuery = NSMetadataQuery()
            self.metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            NotificationCenter.default.addObserver(self, selector: #selector(self.queryDidFinishGathering(_:)), name: .NSMetadataQueryDidFinishGathering, object: self.metadataQuery)
            self.metadataQuery?.start()
        }
    }
    
    @objc private func queryDidFinishGathering(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let query = self.metadataQuery else { return }
            
            for item in query.results {
                if let metadataItem = item as? NSMetadataItem, let fileURL = metadataItem.value(forAttribute: NSMetadataItemURLKey) as? URL {
                    self.ensureFileIsDownloaded(metadataItem: metadataItem, fileURL: fileURL)
                }
            }
            
            self.metadataQuery?.stop()
            self.metadataQuery = nil
        }
    }
    
    private func ensureFileIsDownloaded(metadataItem: NSMetadataItem, fileURL: URL) {
        guard let downloadingStatus = metadataItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String, downloadingStatus == NSMetadataUbiquitousItemDownloadingStatusNotDownloaded else { return }
        try? FileManager.default.startDownloadingUbiquitousItem(at: fileURL)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
