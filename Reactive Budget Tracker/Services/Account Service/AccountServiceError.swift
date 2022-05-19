//
//  AccountServiceError.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 16.05.2022.
//

import Foundation

enum AccountServiceError: Error {
    case accountDidNotFound
    case accountFetchError(Error)
    case currentAccountUUIDDoesNotSet
}
