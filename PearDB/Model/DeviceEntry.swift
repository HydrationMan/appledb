//
//  DeviceEntry.swift
//  PearDB
//
//  Created by Kane Parkinson on 06/02/2025.
//

import Foundation
import CoreData

final class Entry: NSManagedObject, Identifiable {
    @NSManaged var type: String?
    @NSManaged var soc: String?
    @NSManaged var released: Date?
    @NSManaged var name: String?
    @NSManaged var model: [String]?
    @NSManaged var key: String?
    @NSManaged var isMain: Bool
    @NSManaged var identifier: [String]?
    @NSManaged var firmware: String?
    @NSManaged var cpid: String?
    @NSManaged var board: [String]?
    @NSManaged var bdid: String?
    @NSManaged var arch: String?
    @NSManaged var serial: String?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(false, forKey: "isMain")
    }
    
}
