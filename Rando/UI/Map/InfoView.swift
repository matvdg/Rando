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
    @Binding var isPlayingTour: Bool
    @State var isOffline: Bool = UserDefaults.isOffline
    @State private var showAlert = false
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 20.0) {
                
                Picker(selection: $selectedLayer, label: Text("")) {
                    ForEach(Layer.allCases, id: \.self) { layer in
                        Text(layer.localized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
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
                    Text("EmptyCache".localized)
                        .foregroundColor(.text)
                    Spacer()
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
                .frame(height: 20, alignment: .top)
                
            }.padding()
                
                .navigationBarTitle(Text("MapSettings".localized), displayMode: .inline)
                .navigationBarItems(leading:
                    Button(action: {
                        self.isInfoDisplayed.toggle()
                        Feedback.selected()
                    }) {
                        Image(systemName: "chevron.down")
                    },
                                    trailing:
                    Button(action: {
                        self.selectedLayer = .flyover
                        self.isInfoDisplayed = false
                        self.isPlayingTour.toggle()
                        Feedback.selected()
                    }) {
                        Text("Tour")
                    }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\("Delete".localized) (\(TileManager.shared.getCacheSize()))"),
                message: Text("DeleteCache".localized),
                primaryButton: .destructive(Text("Delete".localized), action: { TileManager.shared.removeCache() }),
                secondaryButton: .cancel(Text("Cancel".localized)))
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .frame(maxWidth: 500)
        .frame(height: 200.0, alignment: .top)
        .shadow(radius: 10)
        .gesture(DragGesture().onEnded { value in
            if value.translation.height > 100 {
                self.isInfoDisplayed.toggle()
                Feedback.selected()
            }
        })
        
        
    }
    
}

// MARK: Previews
struct InfoView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign
    @State static var isInfoDisplayed = true
    @State static var isPlayingTour = false
    @State static var isOffline = false
    static var previews: some View {
        Group {
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed, isPlayingTour: $isPlayingTour)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro Max"))
                .previewDisplayName("iPhone 11 Pro Max")
                .environment(\.colorScheme, .dark)
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed, isPlayingTour: $isPlayingTour)
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (3rd generation)"))
                .previewDisplayName("iPad Pro")
                .environment(\.colorScheme, .light)
            InfoView(selectedLayer: $selectedLayer, isInfoDisplayed: $isInfoDisplayed, isPlayingTour: $isPlayingTour)
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
                .previewDisplayName("iPhone SE")
                .environment(\.colorScheme, .light)
        }
        
    }
}
