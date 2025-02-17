//
//  imageLoader.swift
//  PearDB
//
//  Created by Kane Parkinson on 04/02/2025.
//

import SwiftUI

struct AsyncImageView: View {
    let url: String
    #if os(iOS)
    @State private var image: UIImage?
    #endif
    #if os(tvOS)
    @State private var image: UIImage?
    #endif
    #if os(macOS)
    @State private var image: NSImage?
    #endif
    #if os(visionOS)
    @State private var image: UIImage?
    #endif
    #if os(watchOS)
    @State private var image: UIImage?
    #endif
    @State private var loadingState: LoadingState = .loading
    
    enum LoadingState {
        case loading, success, failed
    }
    
    var body: some View {
        Group {
            switch loadingState {
            case .loading:
                ProgressView()
            case .success:
                if let image = image {
                    #if os(iOS)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    #endif
                    #if os(tvOS)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    #endif
                    #if os(macOS)
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                    #endif
                    #if os(visionOS)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    #endif
                    #if os(watchOS)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    #endif
                    
                }
            case .failed:
                Color.clear
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let encodedUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
        guard let url = URL(string: encodedUrlString) else {
            print("❌ Invalid Image URL: \(encodedUrlString)")
            loadingState = .failed
            return
        }
        
        print("🌍 Fetching Image: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle network error
            if let error = error {
                print("❌ Image Fetch Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.loadingState = .failed
                }
                return
            }

            // Handle HTTP response error
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    print("❌ Image not found (404) for URL: \(url.absoluteString)")
                } else if httpResponse.statusCode != 200 {
                    print("❌ HTTP Error: \(httpResponse.statusCode) for Image URL: \(url.absoluteString)")
                }
                
                if httpResponse.statusCode != 200 && httpResponse.statusCode != 404 {
                    DispatchQueue.main.async {
                        self.loadingState = .failed
                    }
                }
            }

            // Handle image data
            #if os(iOS)
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ No valid image data received for URL: \(url.absoluteString)")
                DispatchQueue.main.async {
                    self.loadingState = .failed
                }
                return
            }
            #endif
            #if os(tvOS)
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ No valid image data received for URL: \(url.absoluteString)")
                DispatchQueue.main.async {
                    self.loadingState = .failed
                }
                return
            }
            #endif
            #if os(macOS)
            guard let data = data, let img = NSImage(data: data) else {
                print("❌ No valid image data received for URL: \(url.absoluteString)")
                DispatchQueue.main.async {
                    self.loadingState = .failed
                }
                return
            }
            #endif
            #if os(visionOS)
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ No valid image data received for URL: \(url.absoluteString)")
                DispatchQueue.main.async {
                    self.loadingState = .failed
                }
                return
            }
            #endif
            #if os(watchOS)
            guard let data = data, let img = UIImage(data: data) else {
                print("❌ No valid image data received for URL: \(url.absoluteString)")
                DispatchQueue.main.async {
                    self.loadingState = .failed
                }
                return
            }
            #endif
            DispatchQueue.main.async {
                self.image = img
                self.loadingState = .success
            }
        }.resume()
    }
}
