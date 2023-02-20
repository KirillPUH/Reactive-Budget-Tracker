import UIKit
import CoreData
import RxSwift

class ManagedObjectContextService: ManagedObjectContextServiceProtocol {    
    public let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    public func saveContext() throws {
        if managedObjectContext.hasChanges {
            try managedObjectContext.save()
        }
    }
    
    public func rollbackContext() {
        managedObjectContext.rollback()
    }
    
    public func fetch<T>(_ fetchRequest: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult {
        return try managedObjectContext.fetch(fetchRequest)
    }
    
    public func delete(_ object: NSManagedObject) {
        managedObjectContext.delete(object)
    }
}
