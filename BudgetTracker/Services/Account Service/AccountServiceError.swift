import Foundation

enum AccountServiceError: Error {
    case accountDidNotFound
    case accountFetchError(Error)
    case currentAccountUUIDDoesNotSet
}
