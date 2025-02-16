//
//  AppleDBDownloader.swift
//  PearDB
//
//  Created by Kane Parkinson on 09/02/2025.
//

import Foundation

@MainActor
class AppleDBDownloader: ObservableObject {
    static let shared = AppleDBDownloader()
    
    private let urls = [
        "ios_main": "https://api.appledb.dev/ios/main.json",
        "ios_index": "https://api.appledb.dev/ios/index.json",
        "device_main": "https://api.appledb.dev/device/main.json",
        "device_index": "https://api.appledb.dev/device/index.json"
    ]
    
    private let fileManager = FileManager.default
    private let localDirectory: URL
    private let lastDownloadKey = "lastAppleDBDownload"
    private let downloadInterval: TimeInterval = 86400 // 24 hours
    
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading = false
    
    init() {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.localDirectory = documentDirectory.appendingPathComponent("AppleDB")
        createDirectoryIfNeeded()
    }
    
    /// Checks if data should be redownloaded
    func shouldDownload() -> Bool {
        if let lastDownload = UserDefaults.standard.object(forKey: lastDownloadKey) as? Date {
            return Date().timeIntervalSince(lastDownload) > downloadInterval
        }
        return true
    }
    
    /// Asynchronously triggers download if needed
    func downloadAllIfNeeded() async throws {
        guard shouldDownload() else { return }
        try await downloadAllJSONs()
    }
    
    /// Asynchronously downloads all JSON files
    private func downloadAllJSONs() async throws {
        isDownloading = true
        downloadProgress = 0.0
        
        let totalFiles = urls.count
        var completedFiles = 0
        
        for (key, urlString) in urls {
            guard let url = URL(string: urlString) else { continue }
            let destinationURL = localDirectory.appendingPathComponent("\(key).json")

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                try data.write(to: destinationURL, options: .atomic)

                // Safe mutation since the entire class runs on @MainActor
                completedFiles += 1
                self.downloadProgress = Double(completedFiles) / Double(totalFiles)

                if completedFiles == totalFiles {
                    UserDefaults.standard.set(Date(), forKey: self.lastDownloadKey)
                    self.isDownloading = false
                }
            } catch {
                throw error
            }
        }
    }
    
    /// Loads a local JSON file
    func loadLocalJSON(named key: String) -> Data? {
        let fileURL = localDirectory.appendingPathComponent("\(key).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("❌ File not found: \(fileURL.path)")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            print("✅ Successfully loaded JSON: \(key), size: \(data.count) bytes")
            return data
        } catch {
            print("❌ Error reading JSON file \(key): \(error)")
            return nil
        }
    }
    
    /// Asynchronously purges all downloaded data
    func purgeData() async throws {
        let contents = try fileManager.contentsOfDirectory(atPath: localDirectory.path)
        
        for file in contents {
            let fileURL = localDirectory.appendingPathComponent(file)
            do {
                try fileManager.removeItem(at: fileURL)
                print("🗑 Deleted: \(file)")
            } catch {
                print("❌ Failed to delete \(file): \(error)")
                throw error
            }
        }
        
        UserDefaults.standard.removeObject(forKey: lastDownloadKey)
        
        // Ensure UI refresh
        await MainActor.run {
            objectWillChange.send()  // Notifies views of the change
        }
    }
    
    /// Ensures the directory exists
    private func createDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: localDirectory.path) {
            do {
                try fileManager.createDirectory(at: localDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating AppleDB directory: \(error.localizedDescription)")
            }
        }
    }
}
