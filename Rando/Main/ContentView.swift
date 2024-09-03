//
//  ContentView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit
import HidableTabView
import TipKit

struct ContentView: View {
    
    @State private var selection = 0
    @StateObject var appManager = AppManager.shared
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                HomeView()
                    .tabItem {
                        Label("Map", systemImage: "map.fill")
                    }
                    .tag(0)
                TrailsView()
                    .tabItem {
                        Label("Trails", systemImage: "point.topleft.down.curvedto.point.filled.bottomright.up")
                    }
                    .tag(1)
                PoiView()
                    .tabItem {
                        Label("Steps", systemImage: "mappin.and.ellipse")
                    }
                    .tag(2)
                CollectionView()
                    .tabItem {
                        Label("Collection", systemImage: "trophy")
                    }
                    .tag(3)
                SettingsView(selection: $selection)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(4)
            }
            .environmentObject(appManager)
        }
        .accentColor(Color.tintColorTabBar)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            // correct the transparency bug for Navigation bars
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            UITabBar.showTabBar(animated: false)
            if #available(iOS 17.0, *) {
                try? Tips.configure([.displayFrequency(.immediate)])
            }
        }
        .onChange(of: appManager.isLocked) { newValue in
            if newValue {
                UITabBar.hideTabBar(animated: false)
            } else {
                UITabBar.showTabBar(animated: false)
            }
        }
    }
        
}


// MARK: Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
                .previewDisplayName("iPhone 14 pro")
                .environment(\.colorScheme, .light)
        }
    }
}
