//
//  WebView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 13/06/2023.
//  Copyright © 2024 Mathieu Vandeginste. All rights reserved.
//

import Foundation

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
