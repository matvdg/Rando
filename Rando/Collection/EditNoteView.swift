//
//  EditNoteView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct EditNoteView: View {
    
    var collectedPoi: CollectedPoi
    
    @ObservedObject var collectionManager = CollectionManager.shared
    @Binding var showEditNoteSheet: Bool
    @State var noteInput: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                GroupBox {
                    Section(header: Text("personalNote").bold()) {
                        TextField("typeHere", text: $noteInput, axis: .vertical)
                            .focused($isFocused)
                            .lineLimit(15...15)
                            .textInputAutocapitalization(.sentences)
                            .focused($isFocused)
                    }
                }
                .padding()
                .listStyle(.insetGrouped)
                .navigationBarTitle("edit", displayMode: .inline)
                .navigationBarItems(leading:
                                        Button("cancel", action: {
                    showEditNoteSheet = false
                })
                .foregroundColor(.tintColorTabBar)
                                    , trailing:
                                        Button("save", action: {
                    collectionManager.editNotes(collectedPoi: collectedPoi, notes: noteInput)
                    showEditNoteSheet = false
                })
                .foregroundColor(.tintColorTabBar))
                Spacer()
            }
        }
        .onAppear {
            isFocused = true
            noteInput = collectedPoi.notes ?? ""
        }
        
    }
}

#Preview {
    EditNoteView(collectedPoi: CollectionManager.shared.demoCollection, showEditNoteSheet: .constant(true))
}
