//
//  jsonModel.swift
//  PearDB
//
//  Created by Kane Parkinson on 04/02/2025.
//

import Foundation

// Model for main.json or {key}.json response
struct Device: Codable, Identifiable {
    var id: String { key }
    let name: String
    let identifier: [String]?
    let socRaw: SOCType?  // Use a custom enum for handling multiple types
    let cpidRaw: CPIDType?
    let arch: String?
    let type: String?
    let board: [String]?
    let bdid: String?
    let model: [String]?
    let info: [DeviceInfo]?
    let key: String

    let releasedRaw: ReleasedType?  // Handle multiple formats

    var soc: String? {
        switch socRaw {
        case .single(let string): return string
        case .array(let strings): return strings.joined(separator: ", ")  // Convert array to string
        case .none: return nil
        }
    }
    
    var cpid: String? {
        switch cpidRaw {
        case .single(let string): return string
        case .array(let strings): return strings.joined(separator: ", ")
        case .none: return nil
        }
    }

    var released: String? {
        switch releasedRaw {
        case .single(let string): return string
        case .array(let strings): return strings.joined(separator: ", ")
        case .none: return nil
        }
    }
    
    

    enum SOCType: Codable {
        case single(String)
        case array([String])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .single(string)
            } else if let strings = try? container.decode([String].self) {
                self = .array(strings)
            } else {
                throw DecodingError.typeMismatch(SOCType.self,
                    DecodingError.Context(codingPath: decoder.codingPath,
                    debugDescription: "Invalid type for SOCType"))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .single(let string): try container.encode(string)
            case .array(let strings): try container.encode(strings)
            }
        }
    }
    
    enum CPIDType: Codable {
        case single(String)
        case array([String])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .single(string)
            } else if let strings = try? container.decode([String].self) {
                self = .array(strings)
            } else {
                throw DecodingError.typeMismatch(SOCType.self,
                    DecodingError.Context(codingPath: decoder.codingPath,
                    debugDescription: "Invalid type for CPIDType"))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .single(let string): try container.encode(string)
            case .array(let strings): try container.encode(strings)
            }
        }
    }

    enum ReleasedType: Codable {
        case single(String)
        case array([String])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            // Try to decode a single string
            if let string = try? container.decode(String.self) {
                self = .single(string)
            }
            // Try to decode an array of strings
            else if let strings = try? container.decode([String].self) {
                self = .array(strings)
            }
            else {
                throw DecodingError.typeMismatch(ReleasedType.self,
                    DecodingError.Context(codingPath: decoder.codingPath,
                                          debugDescription: "Invalid type for ReleasedType"))
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .single(let string):
                try container.encode(string)
            case .array(let strings):
                try container.encode(strings)
            }
        }
    }
}

// Model for memory/storage info
struct DeviceInfo: Codable {
    let type: String
    let Storage: String?
    let RAM: String?

    enum CodingKeys: String, CodingKey {
        case type, Storage, RAM
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        // Decode Storage as either a String or an Array
        if let storageString = try? container.decode(String.self, forKey: .Storage) {
            Storage = storageString
        } else if let storageArray = try? container.decode([String].self, forKey: .Storage) {
            Storage = storageArray.joined(separator: ", ")
        } else {
            Storage = nil
        }

        // Decode RAM as either a String or an Array
        if let ramString = try? container.decode(String.self, forKey: .RAM) {
            RAM = ramString
        } else if let ramArray = try? container.decode([String].self, forKey: .RAM) {
            RAM = ramArray.joined(separator: ", ")
        } else {
            RAM = nil
        }
    }
}

class DeviceDetailViewModel: ObservableObject {
    @Published var device: Device?
    
    func loadDevice(key: String) {
        AppleDBService().fetchDeviceDetails(for: key) { [weak self] fetchedDevice in
            DispatchQueue.main.async {
                self?.device = fetchedDevice
            }
        }
    }
}
