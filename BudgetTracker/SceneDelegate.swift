import UIKit
import CoreData
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let sceneCoordinator = SceneCoordinator(window: window!)
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let managedObjectContextService = ManagedObjectContextService(managedObjectContext: managedObjectContext)
        let tabBarViewModel = TabBarViewModel(sceneCoordinator: sceneCoordinator,
                                              managedObjectContextService: managedObjectContextService)
        sceneCoordinator.transition(to: .tabBarController(tabBarViewModel), with: .root)
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
}
