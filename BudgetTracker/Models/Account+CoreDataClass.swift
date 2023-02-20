import CoreData
import RxDataSources

@objc(Account)
public class Account: NSManagedObject {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        
        id = UUID()
    }
}

extension Account: IdentifiableType {
    public typealias Identity = UUID
    
    public var identity: UUID {
        id!
    }
}
