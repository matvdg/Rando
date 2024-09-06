//
//  CollectionDateView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 05/09/2024.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

struct EditDateView: View {
    
    var collectedPoi: CollectedPoi
    
    @ObservedObject var collectionManager = CollectionManager.shared
    @Binding var showEditDateSheet: Bool
    @State var date: Date = Date()
    
    var body: some View {
        
        NavigationView {
            
            List {
                
                DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute]).datePickerStyle(.graphical).padding()
                
            }
            .listStyle(.insetGrouped)
            .navigationBarTitle("editDate", displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("cancel", action: {
                showEditDateSheet = false
            })
                                        .foregroundColor(.tintColorTabBar)
                                , trailing:
                                    Button("save", action: {
                collectionManager.editDate(collectedPoi: collectedPoi, newDate: date)
                showEditDateSheet = false
            })
                                        .foregroundColor(.tintColorTabBar))
        }
        .onAppear {
            date = collectedPoi.date
        }
        
    }
}

#Preview {
    EditDateView(collectedPoi: CollectionManager.shared.demoCollection, showEditDateSheet: .constant(true))
}
