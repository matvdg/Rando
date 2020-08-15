//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Layer: String, CaseIterable, Equatable {
    case ign, standard, satellite, flyover
    var localized: String { self.rawValue.localized }
}

struct InfoView: View {
    
    @Binding var selectedLayer: Layer
    @Binding var isInfoDisplayed: Bool
    @State var isOffline: Bool = UserDefaults.isOffline
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20.0) {
                
                HStack {
                    Text("MapSettings".localized)
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    Button(action: {
                        self.isInfoDisplayed.toggle()
                        Feedback.selected()
                    }) {
                        DismissButton()
                    }
                }
                .offset(y: -10)
                
                Picker(selection: $selectedLayer, label: Text("")) {
                    ForEach(Layer.allCases, id: \.self) { layer in
                        Text(layer.localized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                
                Divider()
                
                Toggle(isOn: self.$isOffline) {
                    Text("MapOfflineSwitcher".localized)
                }
                .onTapGesture {
                    self.isOffline.toggle()
                    UserDefaults.isOffline = self.isOffline
                }
                
                Button(action: {
                    self.showAlert = true
                }) {
                    Text("DeleteTiles".localized)
                        .foregroundColor(.text)
                    Spacer()
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
                
            }
            .padding()
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .actionSheet(isPresented: $showAlert) {
            ActionSheet(
                title: Text("\("Delete".localized) (\(TileManager.shared.getAllDownloadedSize()))"),
                message: Text("DeleteAllTiles".localized),
                buttons: [
                    .destructive(Text("Delete".localized), action: { TileManager.shared.removeAll() }),
                    .cancel(Text("Cancel".localized))
                ]
            )
        }
        .frame(maxWidth: 500)
        .frame(height: 250.0, alignment: .top)
        .cornerRadius(8)
        .shadow(radius: 10)
    }
    
}

// MARK: Previews
struct InfoView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    @State static var isInfoDisplayed = true
    @State static var isOffline = false
    static var previews: some View {
        Group {
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                .previewDisplayName("iPad Pro")
                
                .environment(\.colorScheme, .light)
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
    }
}
