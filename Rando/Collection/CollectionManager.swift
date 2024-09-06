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
    
    var demoCollection: CollectedPoi {
        CollectedPoi(id: UUID(), poi: PoiManager.shared.demoPoi, date: Date(), description: "test", photosURL: [
            URL(string: "https://raw.githubusercontent.com/matvdg/Rando/master/photos/holzarte.heic"),
            URL(string:"https://raw.githubusercontent.com/matvdg/Rando/master/photos/lacrius.jpeg"),
            URL(string:"https://raw.githubusercontent.com/matvdg/Rando/master/photos/cagire.jpeg")
        ])
    }
    
    @Published var collection = [CollectedPoi]()
    
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
            let newPoi = CollectedPoi(id: UUID(), poi: poi, date: Date(), description: nil, photosURL: nil)
            collection.append(newPoi)
        }
        save(collection: collection)
    }
    
    func save(collectedPoi: CollectedPoi) {
        guard let index = self.collection.firstIndex(where: { $0.id == collectedPoi.id }) else { return }
        collection[index] = collectedPoi
        save(collection: collection)
    }
    
    func save(collection: [CollectedPoi]) {
        let file = "collection.json"
        let filename = FileManager.documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(collection)
            try data.write(to: filename)
        } catch {
            print("􀌓 Trail persistLocallyError = \(error)")
        }
    }
    
    func editDate(collectedPoi: CollectedPoi, newDate: Date) {
        var collectedPoi = collectedPoi
        collectedPoi.editDate(newDate: newDate)
        save(collectedPoi: collectedPoi)
    }
    
    func editDescription(collectedPoi: CollectedPoi, description: String) {
        var collectedPoi = collectedPoi
        collectedPoi.description = description
        save(collectedPoi: collectedPoi)
    }
    
    func editPhotosUrl(collectedPoi: CollectedPoi, photosUrl: [URL?]?) {
        var collectedPoi = collectedPoi
        collectedPoi.photosURL = photosUrl
        save(collectedPoi: collectedPoi)
    }
    
    private func getCollection() -> [CollectedPoi] {
        let url = FileManager.documentsDirectory.appendingPathComponent("collection.json")
      do {
        let data = try Data(contentsOf: url)
        let collection = try JSONDecoder().decode([CollectedPoi].self, from: data)
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
