//
//  CollectionManager.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 01/09/2023.
//  Copyright © 2023 Mathieu Vandeginste. All rights reserved.
//

import Foundation

class CollectionManager: ObservableObject {
    
    static let shared = CollectionManager()
    
    @Published var collection = [Collection]()
    
    init() {
        collection = getCollection()
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
