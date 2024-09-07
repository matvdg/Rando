//
//  CollectionManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class CollectionManager: ObservableObject {
    
    static let shared = CollectionManager()
    
    var demoCollection: CollectedPoi {
        CollectedPoi(poi: PoiManager.shared.demoPoi, date: Date())
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
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.notificationsLocked = false
                self.collection = self.getCollection()
                print("􂆍 iCloud update for collection")
            }
        }
    }
    
    func watchiCloud() {
        DispatchQueue.main.async {
            let iCloudDocumentsURL = FileManager.documentsDirectory.appendingPathComponent("collection")
            self.metadataQuery = NSMetadataQuery()
            let predicate = NSPredicate(format: "%K BEGINSWITH %@", NSMetadataItemPathKey, iCloudDocumentsURL.path)
            self.metadataQuery = NSMetadataQuery()
            self.metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            self.metadataQuery?.predicate = predicate
            NotificationCenter.default.addObserver(self, selector: #selector(self.queryDidUpdate(_:)), name: .NSMetadataQueryDidUpdate, object: self.metadataQuery)
            self.metadataQuery?.operationQueue?.addOperation {
                self.metadataQuery?.start()
            }
        }
    }
    
    func unwatchiCloud() {
        NotificationCenter.default.removeObserver(self)
        self.metadataQuery?.operationQueue?.addOperation {
            self.metadataQuery?.stop()
        }
    }
    
    func isPoiAlreadyCollected(poi: Poi) -> Bool {
        collection.contains(where: { $0.poi.name == poi.name })
    }
    
    func addOrRemovePoiToCollection(poi: Poi) {
        if isPoiAlreadyCollected(poi: poi) { // Remove
            collection.removeAll { $0.poi.name == poi.name }
        } else { // Add
            let newPoi = CollectedPoi(poi: poi, date: Date())
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
        let folder = FileManager.Folder.collection.rawValue
        let file = "\(folder)/\(folder).json"
        let filename = FileManager.documentsDirectory.appendingPathComponent(file)
        do {
            let data = try JSONEncoder().encode(collection)
            try data.write(to: filename)
        } catch {
            print("􀌓 Trail persistLocallyError = \(error)")
        }
    }
    
    func editDate(collectedPoi: CollectedPoi, newDate: Date) {
        collectedPoi.date = newDate
        save(collectedPoi: collectedPoi)
    }
    
    func editNotes(collectedPoi: CollectedPoi, notes: String) {
        collectedPoi.notes = notes
        save(collectedPoi: collectedPoi)
    }
    
    func editPhotosUrl(collectedPoi: CollectedPoi, photosUrl: [String]?) {
        collectedPoi.photosUrl = photosUrl
        save(collectedPoi: collectedPoi)
    }
    
    func loadImage(name: String) -> ImageWithId? {
        let fileUrl = FileManager.documentsDirectory.appendingPathComponent(FileManager.Folder.collectionUserPictures.rawValue).appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                let data = try Data(contentsOf: fileUrl)
                let id: UUID = UUID(uuidString: String(name.split(separator: ".").first!))!
                if let uiImage = UIImage(data: data) {
                    return ImageWithId(id: id, image: Image(uiImage: uiImage))
                } else {
                    return nil
                }
            } catch {
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
       
    func saveCollectionUserPicture(image: UIImage, collectedPoi: CollectedPoi) {
        guard let data = image.jpegData(compressionQuality: 0) else { return }
        let fileName = UUID().uuidString + ".jpeg"
        let fileUrl = FileManager.documentsDirectory.appendingPathComponent(FileManager.Folder.collectionUserPictures.rawValue).appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: FileManager.documentsDirectory.appendingPathComponent(FileManager.Folder.collectionUserPictures.rawValue), withIntermediateDirectories: true, attributes: [:])
            try data.write(to: fileUrl)
        } catch {
            print(error.localizedDescription)
        }
        var photosUrl = collectedPoi.photosUrl ?? []
        photosUrl.append(fileUrl.lastPathComponent)
        editPhotosUrl(collectedPoi: collectedPoi, photosUrl: photosUrl)
    }
    
    func deleteCollectionUserPicture(id: UUID, collectedPoi: CollectedPoi) {
        let fileName = "\(id).jpeg"
        let fileUrl = FileManager.documentsDirectory.appendingPathComponent(FileManager.Folder.collectionUserPictures.rawValue).appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileUrl)
            var photosUrl = collectedPoi.photosUrl ?? []
            photosUrl.removeAll { $0 == fileName }
            editPhotosUrl(collectedPoi: collectedPoi, photosUrl: photosUrl)
        } catch {
            print("􀈾 RemovePhotoError = \(error)")
        }
    }
    
    private func getCollection() -> [CollectedPoi] {
        let folder = FileManager.Folder.collection.rawValue
        let url = FileManager.documentsDirectory.appendingPathComponent("\(folder)/\(folder).json")
      do {
          try FileManager.default.createDirectory(at: FileManager.documentsDirectory.appendingPathComponent(FileManager.Folder.collection.rawValue), withIntermediateDirectories: true, attributes: [:])
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
