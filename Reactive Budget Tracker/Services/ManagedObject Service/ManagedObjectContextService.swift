//
//  ManagedObjectContextService.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import Foundation
import UIKit
import RxSwift

class ManagedObjectContextService: ManagedObjectContextServiceProtocol {
    static public let shared = ManagedObjectContextService()
    
    func saveContext() throws {
        try context.save()
    }
    
    func rollbackContext() {
        context.rollback()
    }
}
