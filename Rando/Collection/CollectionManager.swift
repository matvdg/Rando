//
//  CollectionManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

class CollectionManager: ObservableObject {
    
    static let shared = CollectionManager()
    
    @Published var collection = [Collection]()
    
    private var metadataQuery: NSMetadataQuery?
    private var notificationsLocked: Bool = false
        
    init() {
        collection = getCollection()
    }
    
    @objc private func queryDidUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            guard !self.notificationsLocked else { return }
            self.notificationsLocked = true
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                self.notificationsLocked = false
                self.collection = self.getCollection()
                print("􂆍 iCloud update for collection")
            }
        }
    }
    
    func watchiCloud() {
        DispatchQueue.main.async {
            self.metadataQuery = NSMetadataQuery()
            self.metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            self.metadataQuery?.predicate = NSPredicate(format: "%K == %@", NSMetadataItemFSNameKey, "collection.json")
            NotificationCenter.default.addObserver(self, selector: #selector(self.queryDidUpdate(_:)), name: .NSMetadataQueryDidUpdate, object: self.metadataQuery)
            self.metadataQuery?.start()
        }
    }
    
    func unwatchiCloud() {
        NotificationCenter.default.removeObserver(self)
        metadataQuery?.stop()
    }
    
    func isPoiAlreadyCollected(poi: Poi) -> Bool {
        collection.contains(where: { $0.poi.name == poi.name })
    }
    
    func addOrRemovePoiToCollection(poi: Poi) {
        if isPoiAlreadyCollected(poi: poi) { // Remove
            collection.removeAll { $0.poi.name == poi.name }
        } else { // Add
            let newPoi = Collection(id: UUID(), poi: poi, date: Date())
            collection.append(newPoi)
        }
        let file = "collection.json"
        let filename = FileManager.documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(collection)
            try data.write(to: filename)
        } catch {
            print("􀌓 Trail persistLocallyError = \(error)")
        }
    }
    
    private func getCollection() -> [Collection] {
        let url = FileManager.documentsDirectory.appendingPathComponent("collection.json")
      do {
        let data = try Data(contentsOf: url)
        let collection = try JSONDecoder().decode([Collection].self, from: data)
        print("􀎫 Collection = \(collection.count)")
        return collection
      } catch {
        switch error {
        case DecodingError.keyNotFound(let key, let context): print("􀎫 Decoding collection error = \(error.localizedDescription), key not found = \(key), context = \(context)")
        default: print("􀎫 Decoding collection error = \(error.localizedDescription)")
        }
        return []
      }
    }
}
