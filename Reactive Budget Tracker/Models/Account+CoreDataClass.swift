//
//  Account+CoreDataClass.swift
//  iOS App
//
//  Created by Kirill Pukhov on 15.04.2022.
//
//

import Foundation
import CoreData
import RxDataSources

@objc(Account)
public class Account: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
    }
}

extension Account: IdentifiableType {
    public typealias Identity = UUID
    
    public var identity: UUID {
        id!
    }
}
