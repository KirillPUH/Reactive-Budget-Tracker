//
//  MainViewModelTests.swift
//  Reactive Budget TrackerTests
//
//  Created by Kirill Pukhov on 22.05.2022.
//

import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxDataSources
import RxTest
import RxBlocking

@testable import Reactive_Budget_Tracker

class MainViewModelTests: XCTestCase {
    var sceneCoordinator: SceneCoordinatorProtocol!
    var managedObjectContextService: ManagedObjectContextServiceProtocol!
    var mainViewModel: MainViewModel!
    
    var disposeBag: DisposeBag!
    var sheduler: TestScheduler!
    
    var account: Account!
    
    var appSelectedAccountUUID: String?
    var testSelectedAccountUUID: String!
    
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
        sceneCoordinator = SceneCoordinator(window: UIWindow())
        managedObjectContextService = ManagedObjectContextService(managedObjectContext: persistentContainer.viewContext)
        mainViewModel = MainViewModel(sceneCoordinator: sceneCoordinator,
                                      managedObjectContextService: managedObjectContextService)
        
        disposeBag = DisposeBag()
        sheduler = TestScheduler(initialClock: 0)
        
        account = Account(context: managedObjectContextService.managedObjectContext)
        
        appSelectedAccountUUID = UserDefaults.standard.string(forKey: "currentAccountUUID")
        testSelectedAccountUUID = account.id!.uuidString
        UserDefaults.standard.set(testSelectedAccountUUID, forKey: "currentAccountUUID")
    }

    override func tearDownWithError() throws {
        sceneCoordinator = nil
        managedObjectContextService = nil
        mainViewModel = nil
        
        disposeBag = nil
        sheduler = nil
        
        account = nil
        
        UserDefaults.standard.set(appSelectedAccountUUID, forKey: "currentAccountUUID")
        appSelectedAccountUUID = nil
        testSelectedAccountUUID = nil
    }
    
    // MARK: - Tests for properties
    
    func testIsPlusButtonEnabledWithOneAccount() throws {
        let fetchRequest = Account.fetchRequest()
        let accounts = try managedObjectContextService.fetch(fetchRequest)
        
        let isPlusButtonEnabledObserver = sheduler.createObserver(Bool.self)
        mainViewModel.isPlusButtonEnabled
            .drive(isPlusButtonEnabledObserver)
            .disposed(by: disposeBag)
        
        XCTAssertEqual(accounts.count != 0, isPlusButtonEnabledObserver.events.first?.value.element)
    }
    
    // MARK: - Tests for tableItems property
    
    func testTableItemsInitialTransactions() throws {
        let transactions = [
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext)
        ]
        
        account.addToTransactions(NSSet(array: transactions))
        
        try managedObjectContextService.saveContext()
        
        let tableItemsObserver = sheduler.createObserver([TransactionsListSection].self)
        mainViewModel.tableItems
            .bind(to: tableItemsObserver)
            .disposed(by: disposeBag)
        
        let events = tableItemsObserver.events
        if let eventTableItems = events[0].value.element {
            let sectionedTransactions = transactions.sortedByDate()
            let sectionsTitles = sectionedTransactions.map { $0.0 }
            let sectionsTransactions = sectionedTransactions.map { $0.1.sorted(by: { $0.date! > $1.date! }) }
            
            let tableSectionsTitles = eventTableItems.map { $0.model }
            let tableSectionsTransactions = eventTableItems.map { $0.items.sorted(by: { $0.date! > $1.date! }) }
            
            XCTAssertEqual(sectionsTitles, tableSectionsTitles)
            XCTAssertEqual(sectionsTransactions, tableSectionsTransactions)
        } else {
            XCTAssert(false)
        }
    }
    
    func testTableItemsAddTransaction() throws {
        var transactions = [
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext)
        ]
        
        account.addToTransactions(NSSet(array: transactions))
        
        try managedObjectContextService.saveContext()
        
        let tableItemsObserver = sheduler.createObserver([TransactionsListSection].self)
        mainViewModel.tableItems
            .bind(to: tableItemsObserver)
            .disposed(by: disposeBag)
        
        transactions.append(Transaction(context: managedObjectContextService.managedObjectContext))
        account.addToTransactions(transactions.last!)
        
        try managedObjectContextService.saveContext()
        
        let events = tableItemsObserver.events
        if let eventTableItems = events[1].value.element {
            let sectionedTransactions = transactions.sortedByDate()
            let sectionsTitles = sectionedTransactions.map { $0.0 }
            let sectionsTransactions = sectionedTransactions.map { $0.1.sorted(by: { $0.date! > $1.date! }) }
            
            let tableSectionsTitles = eventTableItems.map { $0.model }
            let tableSectionsTransactions = eventTableItems.map { $0.items.sorted(by: { $0.date! > $1.date! }) }
            
            XCTAssertEqual(sectionsTitles, tableSectionsTitles)
            XCTAssertEqual(sectionsTransactions, tableSectionsTransactions)
        } else {
            XCTAssert(false)
        }
    }
    
    func testTableItemsDeleteTransaction() throws {
        var transactions = [
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext),
            Transaction(context: managedObjectContextService.managedObjectContext)
        ]
        
        account.addToTransactions(NSSet(array: transactions))
        
        try managedObjectContextService.saveContext()
        
        let tableItemsObserver = sheduler.createObserver([TransactionsListSection].self)
        mainViewModel.tableItems
            .bind(to: tableItemsObserver)
            .disposed(by: disposeBag)
        
        account.removeFromTransactions(transactions.remove(at: 1))
        
        try managedObjectContextService.saveContext()
        
        let events = tableItemsObserver.events
        if let eventTableItems = events[1].value.element {
            let sectionedTransactions = transactions.sortedByDate()
            let sectionsTitles = sectionedTransactions.map { $0.0 }
            let sectionsTransactions = sectionedTransactions.map { $0.1.sorted(by: { $0.date! > $1.date! }) }
            
            let tableSectionsTitles = eventTableItems.map { $0.model }
            let tableSectionsTransactions = eventTableItems.map { $0.items.sorted(by: { $0.date! > $1.date! }) }
            
            XCTAssertEqual(sectionsTitles, tableSectionsTitles)
            XCTAssertEqual(sectionsTransactions, tableSectionsTransactions)
        } else {
            XCTAssert(false)
        }
    }
    
}
