//
//  SearchBar.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 07/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit


struct SearchBar: View {
    
    @State private var searchText: String = ""
    @Binding var searchTilePaths: [MKTileOverlayPath]
    @Binding var selectedSearchTilePath: MKTileOverlayPath?
    @State private var isSearching: Bool = false
    @State private var currentIndex: Int = 0
    @ObservedObject var tileManager = TileManager.shared
    
    var body: some View {
        
        if searchTilePaths.isEmpty {
            HStack {
                if isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.leading, 10)
                } else {
                    Image(systemName: "magnifyingglass") // Icône de loupe
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                }
                TextField("search", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        isSearching = true
                        do {
                            AppManager.shared.selectedTracking = .disabled
                            searchTilePaths = try tileManager.search(text: searchText)
                            selectedSearchTilePath = searchTilePaths.first
                            Feedback.success()
                        } catch {
                            print(error)
                            Feedback.failed()
                        }
                        isSearching = false
                        searchText = ""
                    }
                if isSearching {
                    Button(action: {
                        isSearching = false
                        searchText = ""
                        tileManager.cancelSearch()
                        Feedback.selected()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .padding(.trailing, 10)
                    }
                }
            }
            .padding(.horizontal, 10)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2)
            .frame(maxWidth: 500)
        } else {
            VStack(alignment: .center, spacing: 20) {
                HStack(alignment: .center, spacing: 20) {
                    
                    Button(action: {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            selectedSearchTilePath = searchTilePaths[currentIndex]
                        }
                    }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .foregroundColor(currentIndex > 0 ? .grblue : .gray)
                            .font(.system(size: 50))
                    }
                    .disabled(currentIndex == 0)
                    
                    Text("\(currentIndex + 1)/\(searchTilePaths.count)").font(.largeTitle)
                    
                    Button(action: {
                        if currentIndex < searchTilePaths.count - 1 {
                            currentIndex += 1
                            selectedSearchTilePath = searchTilePaths[currentIndex]
                        }
                    }) {
                        Image(systemName: "chevron.right.circle.fill")
                            .foregroundColor(currentIndex < searchTilePaths.count - 1 ? .grblue : .gray)
                            .font(.system(size: 50))
                            .frame(width: 50, height: 50, alignment: .center)
                    }
                    .disabled(currentIndex == searchTilePaths.count - 1)
                }
                Button(action: {
                    searchTilePaths.removeAll()
                    selectedSearchTilePath = nil
                    searchText = ""
                    isSearching = false
                    currentIndex = 0
                    tileManager.cancelSearch()
                    Feedback.selected()
                }) {
                    Text("ok")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color(.grblue))
                        .clipShape(Capsule())
                        .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2)
            .frame(maxWidth: 500)
        }
    }
    
}

#Preview {
    VStack(alignment: .center, spacing: 30) {
        SearchBar(searchTilePaths: .constant([]), selectedSearchTilePath: .constant(nil))
        SearchBar(searchTilePaths: .constant([MKTileOverlayPath(), MKTileOverlayPath(), MKTileOverlayPath()]), selectedSearchTilePath: .constant(nil))
    }.padding()
}

extension MKTileOverlayPath: Equatable {
    public static func == (lhs: MKTileOverlayPath, rhs: MKTileOverlayPath) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.contentScaleFactor == rhs.contentScaleFactor
    }
}
