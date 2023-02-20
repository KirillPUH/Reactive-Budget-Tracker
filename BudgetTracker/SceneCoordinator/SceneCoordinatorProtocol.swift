import UIKit
import RxSwift

protocol SceneCoordinatorProtocol {
    var window: UIWindow { get set }
    var currentViewController: UIViewController! { get set }
    
    @discardableResult
    func transition(to scene: Scene, with type: SceneTransitionType) -> Completable
    
    @discardableResult
    func pop(animated: Bool) -> Completable
}
