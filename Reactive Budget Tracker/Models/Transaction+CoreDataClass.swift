//
//  Transaction+CoreDataClass.swift
//  iOS App
//
//  Created by Kirill Pukhov on 15.04.2022.
//
//

import Foundation
import CoreData
import RxDataSources

@objc(Transaction)
public class Transaction: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
        date = Date()
    }
}

extension Transaction: IdentifiableType {
    public typealias Identity = UUID
    
    public var identity: UUID {
        if id == nil {
            id = UUID()
        }
        
        return id!
    }
}
