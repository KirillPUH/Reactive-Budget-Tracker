//
//  TransactionsServiceTests.swift
//  iOS AppTests
//
//  Created by Kirill Pukhov on 14.03.2022.
//

import XCTest
import CoreData
import RxSwift
import RxTest
import RxBlocking

@testable import Reactive_Budget_Tracker

class TransactionsServiceTests: XCTestCase {
    
    var managedObjectContextService: ManagedObjectContextServiceProtocol!
    var transactionService: TransactionServiceProtocol!
    
    var account: Account!
    
    var disposeBag: DisposeBag!
    var sheduler: TestScheduler!
    
    var persistentContainer: NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        let container = NSPersistentContainer(name: "iOS_App")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        managedObjectContextService = ManagedObjectContextService(managedObjectContext: persistentContainer.viewContext)
        transactionService = TransactionService(managedObjectContextService: managedObjectContextService)
        
        account = Account(context: managedObjectContextService.managedObjectContext)
        account.title = "Test Account"
        account.currency = Currency.usd.rawValue
        
        try managedObjectContextService.saveContext()
        
        disposeBag = DisposeBag()
        sheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        super.tearDown()
        
        managedObjectContextService.managedObjectContext.reset()
        managedObjectContextService = nil
        transactionService = nil
        
        account = nil
        
        disposeBag = nil
        sheduler = nil
    }
    
    func testCreateTransaction() throws {
        let transaction = transactionService.createTransaction(in: account)
        
        try managedObjectContextService.saveContext()
        
        let accountTransactions = account.transactions?.allObjects as? [Transaction]
        XCTAssert(transaction.account == account)
        XCTAssert(accountTransactions?.count == 1)
    }
    
    func testDeleteTransaction() throws {
        let transaction = Transaction(context: managedObjectContextService.managedObjectContext)
        account.addToTransactions(transaction)
        
        try managedObjectContextService.saveContext()
        
        transactionService.delete(transaction: transaction)
        
        let accountTransactions = account.transactions?.allObjects as? [Transaction]
        XCTAssert(accountTransactions?.count == 0)
    }
    
    func testTransactionsObserverInitialValueWithZeroTransactions() throws {
        let blockingObserver = transactionService.transactions(for: account)
            .take(1)
            .toBlocking()
        
        XCTAssertEqual(try blockingObserver.first(), [])
    }
    
    func testTransactionsObserverInitialValueWith3Transactions() throws {
        var transactions = [
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext)
        ]
        account.addToTransactions(NSSet(array: transactions))
        
        transactions.sort(by: { $0.date! > $1.date!})
        
        try managedObjectContextService.saveContext()
        
        let transactionsObserver = sheduler.createObserver([Transaction].self)
        transactionService.transactions(for: account)
            .bind(to: transactionsObserver)
            .disposed(by: disposeBag)
        
        
        sheduler.start()
        
        let events = transactionsObserver.events
        if let eventTransactions = events[0].value.element {
            let sortedEventTransactions = eventTransactions.sorted(by: { $0.date! > $1.date! })
            XCTAssertEqual(transactions, sortedEventTransactions)
        } else {
            XCTAssert(false)
        }
    }
    
    func testTransactionObserverOnAddTransaction() throws {
        var transactions = [
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext)
        ]
        account.addToTransactions(NSSet(array: transactions))
        
        try managedObjectContextService.saveContext()
        
        let transactionsObserver = sheduler.createObserver([Transaction].self)
        transactionService.transactions(for: account)
            .bind(to: transactionsObserver)
            .disposed(by: disposeBag)
        
        sheduler.start()

        transactions.append(Transaction(context: managedObjectContextService.managedObjectContext))
        account.addToTransactions(transactions[3])

        try managedObjectContextService.saveContext()
        
        transactions.sort(by: { $0.date! > $1.date!})
        
        let events = transactionsObserver.events
        if let eventTransactions = events[1].value.element {
            let sortedEventTransactions = eventTransactions.sorted(by: { $0.date! > $1.date! })
            XCTAssertEqual(transactions, sortedEventTransactions)
        } else {
            XCTAssert(false)
        }
    }
    
    func testTransactionObserverOnDeleteTransaction() throws {
        var transactions = [
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext)
        ]
        account.addToTransactions(NSSet(array: transactions))
        
        transactions.sort(by: { $0.date! > $1.date!})
        
        try managedObjectContextService.saveContext()
        
        let transactionsObserver = sheduler.createObserver([Transaction].self)
        transactionService.transactions(for: account)
            .bind(to: transactionsObserver)
            .disposed(by: disposeBag)
        
        sheduler.start()
        
        let removingTransaction = transactions[1]
        account.removeFromTransactions(removingTransaction)
        transactions.remove(at: 1)
        
        try managedObjectContextService.saveContext()
        
        let events = transactionsObserver.events
        if let eventTransactions = events[1].value.element {
            let sortedEventTransactions = eventTransactions.sorted(by: { $0.date! > $1.date! })
            XCTAssertEqual(transactions, sortedEventTransactions)
        } else {
            XCTAssert(false)
        }
    }
    
}
