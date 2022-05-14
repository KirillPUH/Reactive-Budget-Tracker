//
//  CoreData+Rx.swift
//  iOS App
//
//  Created by Kirill Pukhov on 14.04.2022.
//

import Foundation
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
