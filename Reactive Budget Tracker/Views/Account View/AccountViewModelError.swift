//
//  AccountViewModelError.swift
//  Reactive Budget Tracker
//
//  Created by Kirill Pukhov on 15.05.2022.
//

import Foundation

enum AccountViewModelError: Error {
    case savingContextError(Error)
}
