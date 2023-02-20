import CoreData
import RxSwift
import RxCocoa

extension Reactive where Base: NSManagedObjectContext {
    func didChangedObjects() -> Observable<Void> {
        return NotificationCenter.default.rx
            .notification(NSManagedObjectContext.didChangeObjectsNotification)
            .map { _ in }
    }
    
    func didSaveObjects() -> Observable<Void> {
        return NotificationCenter.default.rx
            .notification(NSManagedObjectContext.didSaveObjectsNotification)
            .map { _ in }
    }
}
