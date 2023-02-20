import CoreData
import RxSwift
import RxCocoa
import RxDataSources

typealias AccountCellModel = SectionModel<String, AccountTableViewCellType>

class AccountViewModel {
    
    private let sceneCoordinator: SceneCoordinatorProtocol
    private let managedObjectContextService: ManagedObjectContextServiceProtocol
    private let accountService: AccountServiceProtocol
    
    public let account: Account
    
    // Rx
    private let disposeBag: DisposeBag
    
    // Inputs
    private(set) var doneAction: PublishSubject<Void>!
    private(set) var cancelAction: PublishSubject<Void>!
    private(set) var chooseCurrencyAction: PublishSubject<Void>!
    
    // Ouputs
    private(set) var tableItems: Observable<[AccountCellModel]>!
    private(set) var isDoneButtonEnabled: Driver<Bool>!
    
    init(for account: Account, sceneCoordinator: SceneCoordinatorProtocol, managedObjectContextService: ManagedObjectContextServiceProtocol) {
        self.sceneCoordinator = sceneCoordinator
        self.managedObjectContextService = managedObjectContextService
        accountService = AccountService(managedObjectContextService: managedObjectContextService)
        
        self.account = account
        if account.currency == nil {
            account.currency = Currency.usd.rawValue
        }
        
        disposeBag = DisposeBag()
        
        configureTableItems()
        configureProperties()
        configureActions()
    }
}

extension AccountViewModel {
    
    private func configureActions() {
        doneAction = PublishSubject<Void>()
        doneAction
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { fatalError() }
                
                do {
                    try self?.managedObjectContextService.saveContext()
                    self?.accountService.changeAccount(to: strongSelf.account)
                    self?.sceneCoordinator.pop(animated: true)
                } catch {
                    self?.managedObjectContextService.rollbackContext()
                    self?.sceneCoordinator.pop(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        cancelAction = PublishSubject<Void>()
        cancelAction
            .subscribe(onNext: { [weak self] in
                self?.managedObjectContextService.rollbackContext()
                self?.sceneCoordinator.pop(animated: true)
            })
            .disposed(by: disposeBag)
        
        chooseCurrencyAction = PublishSubject<Void>()
        chooseCurrencyAction
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else { fatalError() }
                
                let viewModel = CurrenciesViewModel(sceneCoordinator: strongSelf.sceneCoordinator,
                                                    account: strongSelf.account)
                self?.sceneCoordinator.transition(to: .currencies(viewModel), with: .push)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureProperties() {
        isDoneButtonEnabled = account.rx.observe(\.title)
            .map { $0 != nil && $0 != "" }
            .asDriver(onErrorJustReturn: false)
    }
    
    private func configureTableItems() {
        tableItems = Observable.create { Observable in
            Observable.onNext([AccountCellModel(model: "Cells",
                                                items: AccountTableViewCellType.allCases)])
            return Disposables.create { }
        }
    }
    
}
