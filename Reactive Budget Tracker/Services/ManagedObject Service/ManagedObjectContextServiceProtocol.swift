//
//  ManagedObjectContextServiceProtocol.swift
//  iOS App
//
//  Created by Kirill Pukhov on 16.04.2022.
//

import Foundation
import UIKit
import CoreData
import RxSwift

protocol ManagedObjectContextServiceProtocol {
    var context: NSManagedObjectContext { get }
    
    func saveContext() throws
    
    func rollbackContext()
}

extension ManagedObjectContextServiceProtocol {
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
}

