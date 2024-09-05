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
                        Label("map", systemImage: "map.fill")
                    }
                    .tag(0)
                TrailsView()
                    .tabItem {
                        Label("trails", systemImage: "point.topleft.down.curvedto.point.filled.bottomright.up")
                    }
                    .tag(1)
                PoiView()
                    .tabItem {
                        Label("pois", systemImage: "mappin.and.ellipse")
                    }
                    .tag(2)
                CollectionView()
                    .tabItem {
                        Label("collection", systemImage: "trophy")
                    }
                    .tag(3)
                SettingsView(selection: $selection)
                    .tabItem {
                        Label("settings", systemImage: "gearshape")
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
                try? Tips.configure([.displayFrequency(.hourly)])
            }
            iCloudSyncManager.shared.synchronizeAllFilesInBackground()
        }
        .onChange(of: appManager.isMapFullScreen) { newValue in
            if newValue {
                UITabBar.hideTabBar(animated: false)
            } else {
                UITabBar.showTabBar(animated: false)
            }
        }
    }
        
}


// MARK: Preview
#Preview {
    ContentView()
}
