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
    
    @discardableResult
    func saveContext() -> Completable {
        let subject = PublishSubject<Never>()
        
        do {

            try context.save()
            subject.onCompleted()
        } catch {
            subject.onError(error)
        }
    
        return subject.asCompletable()
    }
    
    @discardableResult
    func rollbackContext() -> Completable {
        let subject = PublishSubject<Never>()
        
        context.rollback()
        
        subject.onCompleted()
    
        return subject.asCompletable()
    }
}
