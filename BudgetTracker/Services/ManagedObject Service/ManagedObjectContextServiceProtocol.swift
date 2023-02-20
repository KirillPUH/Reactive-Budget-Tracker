import UIKit
import CoreData
import RxSwift

protocol ManagedObjectContextServiceProtocol {
    var managedObjectContext: NSManagedObjectContext { get }
    
    func saveContext() throws
    
    func rollbackContext()
    
    func delete(_ object: NSManagedObject) 
    
    func fetch<T>(_ fetchRequest: NSFetchRequest<T>) throws -> [T] where T: NSFetchRequestResult
}
