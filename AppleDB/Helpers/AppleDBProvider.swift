//
//  AppleDBProvider.swift
//  AppleDB
//
//  Created by Kane Parkinson on 29/08/2024.
//

import SwiftUI
import Combine
import Foundation
import CoreData

struct FirmwareEntry: Codable, Hashable {
    let osStr: String
    let version: String
    let build: String?
    let internalVersion: Bool?
    let beta: Bool?
    let deviceMap: [String]
    let rc: Bool?
    
    enum CodingKeys: String, CodingKey {
        case osStr, version, build
        case internalVersion = "internal"
        case beta, deviceMap, rc
    }
}

class firmwareModel: ObservableObject {
    @Published var selectedFirmware: FirmwareEntry?
    @Published var buildRC: Bool = false
    @Published var buildBeta: Bool = false
    @Published var buildInternal: Bool = false
    @Published var version: String = ""
    @Published var build: String = ""
    @Published var osStr: String = ""
}

class appleDBPoll: ObservableObject {
    @Published var name: String = ""
    @Published var soc: String = ""
    @Published var arch: String = ""
    @Published var type: String = ""
    @Published var released: String = ""
    @Published var identifier: String = ""
    @Published var response: URLResponse?
    @Published var error: Bool = false
    @Published var board: [String] = []
    private var cancellables = Set<AnyCancellable>()

    func simplefetch() {
        guard let url = URL(string: "https://api.appledb.dev/device/\(identifier).json") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(Device.self, from: data)
                    DispatchQueue.main.async {
                        self.released = decodedData.released.joined(separator: ", ")
                        self.name = decodedData.name
                        self.soc = decodedData.soc
                        self.arch = decodedData.arch
                        self.type = decodedData.type
                        self.board = decodedData.board
                        print("Supported Architectures: \(decodedData.supportedArchitectures)")
                        print("Related Devices: \(decodedData.relatedDevices)")
                        print(decodedData.released)
                        self.response = response
                        self.error = false
                    }
                } catch {
                    print("simplefetch; Error decoding JSON: '\(error)'")
                    print("didFailDecodingJSON Hit")
                    print(url)
                    DispatchQueue.main.async {
                        self.error = true
                    }
                }
            } else if let error = error {
                print("simplefetch; error fetching JSON: \(error)")
                print("didFailFetchingJSON Hit")
                print(url)
                DispatchQueue.main.async {
                    self.error = true
                }
            }
        }.resume()
    }
}

struct DeviceListEntry: Decodable, Hashable {
    var name: String
    var identifier: [String]?
    var soc: String
    var arch: String?
    var type: String
    var board: [String]?
    var model: [String]?
    var released: [String]
    var key: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.identifier = try container.decodeIfPresent([String].self, forKey: .identifier)
        self.arch = try container.decodeIfPresent(String.self, forKey: .arch)
        self.type = try container.decode(String.self, forKey: .type)
        self.board = try container.decodeIfPresent([String].self, forKey: .board)
        self.model = try container.decodeIfPresent([String].self, forKey: .model)
        self.key = try container.decode(String.self, forKey: .key)
        
        if let releasedArray = try? container.decode([String].self, forKey: .released) {
            self.released = releasedArray
        } else if let releasedString = try? container.decode(String.self, forKey: .released) {
            self.released = [releasedString]
        } else {
            self.released = ["Unknown"]
        }
        
        if let socArray = try? container.decode([String].self, forKey: .soc) {
            self.soc = socArray.joined(separator: ", ")
        } else if let socString = try? container.decode(String.self, forKey: .soc) {
            self.soc = socString
        } else {
            self.soc = "Unknown"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case name, identifier, soc, arch, type, board, model, released, key
    }
}

struct Device: Decodable {
    var name: String
    var soc: String
    var arch: String
    var type: String
    var board: [String]
    var released: [String]
    var supportedArchitectures: [String]
    var relatedDevices: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown"
        self.arch = try container.decodeIfPresent(String.self, forKey: .arch) ?? "Unknown"
        self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? "Unknown"
        
        if let releasedArray = try? container.decode([String].self, forKey: .released) {
            self.released = releasedArray
        } else if let releasedString = try? container.decode(String.self, forKey: .released) {
            self.released = [releasedString]
        } else {
            self.released = ["Unknown"]
        }
        
        self.supportedArchitectures = try container.decodeIfPresent([String].self, forKey: .supportedArchitectures) ?? []
        self.relatedDevices = try container.decodeIfPresent([String].self, forKey: .relatedDevices) ?? []
        
        if let socArray = try? container.decode([String].self, forKey: .soc) {
            self.soc = socArray.joined(separator: ", ")
        } else if let socString = try? container.decode(String.self, forKey: .soc) {
            self.soc = socString
        } else {
            self.soc = "Unknown"
        }
        self.board = try container.decodeIfPresent([String].self, forKey: .board) ?? ["Unknown"]
    }

    private enum CodingKeys: String, CodingKey {
        case name, soc, arch, type, board, released, supportedArchitectures, relatedDevices
    }
}

class DeviceViewModel: ObservableObject {
    @Published var devices: [DeviceListEntry] = []
    @Published var selectedDevice: DeviceListEntry?
    @Published var deviceDetails: Device?
    @Published var error: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDeviceList() {
        guard let url = URL(string: "https://api.appledb.dev/device/main.json") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [DeviceListEntry].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching device list: \(error)")
                    self.error = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] devices in
                self?.devices = devices
                self?.error = false
            })
            .store(in: &cancellables)
    }
    
    func fetchDeviceDetails(for device: DeviceListEntry) {
        guard let url = URL(string: "https://api.appledb.dev/device/\(device.key).json") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Device.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching device details: \(error)")
                    self.error = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] deviceDetails in
                self?.deviceDetails = deviceDetails
                self?.error = false
            })
            .store(in: &cancellables)
    }
}

struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    var url: URL?
    @ViewBuilder var content: (Image) -> ImageView
    @ViewBuilder var placeholder: () -> PlaceholderView

    @State private var image: UIImage? = nil

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> ImageView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        VStack {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await downloadPhoto()
                        }
                    }
            }
        }
    }

    // MARK: - Image Download Method
    private func downloadPhoto() async -> UIImage? {
        let fallbackImage = UIImage(named: "Sad") // Use the "Sad" image from the Asset Catalog
        do {
            guard let url else { return fallbackImage }

            // Check if the image is cached
            if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
                return UIImage(data: cachedResponse.data) ?? fallbackImage
            } else {
                // Download the image
                let (data, response) = try await URLSession.shared.data(from: url)
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                return UIImage(data: data) ?? fallbackImage
            }
        } catch {
            print("Error downloading image: \(error)")
            return fallbackImage
        }
    }
}

final class EditHardwareViewModel: ObservableObject {
    @Published var hardware: Hardware
    let isNew: Bool

    private let context: NSManagedObjectContext
    let provider: HardwareProvider

    init(provider: HardwareProvider, hardware: Hardware? = nil) {
        self.provider = provider
        self.context = provider.newContext

        if let hardware,
           let existingHardwareCopy = try? context.existingObject(with: hardware.objectID) as? Hardware {
            self.hardware = existingHardwareCopy
            self.isNew = false
        } else {
            self.hardware = Hardware(context: self.context)
            self.isNew = true
        }
    }

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    func delete() throws {
        context.delete(hardware)
        try saveContext()
    }

    private func saveContext() throws {
        DispatchQueue.global(qos: .background).async {
            self.context.performAndWait {
                do {
                    try self.context.save()
                } catch {
                    print("Failed to save context: \(error)")
                }
            }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    /// The blur's style.
    public var style: UIBlurEffect.Style

    /// Use UIKit blurs in SwiftUI.
    public init(_ style: UIBlurEffect.Style) {
        self.style = style
    }

    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView()
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
