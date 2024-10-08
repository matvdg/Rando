//
//  SceneDelegate.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 02/05/2020.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import UIKit
import SwiftUI
import SwiftData


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            // Create the SwiftUI view that provides the window contents.
            let contentView = ContentView()
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
            
        }
        if let urlContext = connectionOptions.urlContexts.first {
            self.loadGpx(url: urlContext.url, scene: scene)
        }
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        if let scheme = url.scheme, scheme.contains("rando") { // rando://xxx scheme
            self.loadUserPosition(url: url, scene: scene)
        } else {
            self.loadGpx(url: url, scene: scene)
        }
    }
    
    private func loadUserPosition(url: URL, scene: UIScene) {
        if let windowScene = scene as? UIWindowScene, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true), let lat = Double(urlComponents.queryItems?.first?.value ?? ""), let lng = Double(urlComponents.queryItems?.last?.value ?? "") {
            let window = UIWindow(windowScene: windowScene)
            let location = Location(latitude: lat, longitude: lng, altitude: nil)
            let contentView = UserView(location: location)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private func loadGpx(url: URL, scene: UIScene) {
        print("url = \(url)")
        let trailManager = TrailManager.shared
        guard let trail = trailManager.loadTrails(from: [url]).first else { return }
        trailManager.save(trail: trail)
        NotificationManager.shared.sendNotification(title: "gpxImported".localized, message: trail.name)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

