import RxSwift

protocol TransactionServiceProtocol {
    func transactions(for account: Account) -> Observable<[Transaction]>
    
    @discardableResult
    func createTransaction(in account: Account) -> Transaction
    
    func delete(transaction: Transaction)
}
