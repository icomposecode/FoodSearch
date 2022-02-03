import UIKit

enum AppStep {
    case showListViewController
}

class AppCoordinator: Coordinator<AppStep> {
    private weak var appWindow: UIWindow?
    
    init(window: UIWindow) {
        appWindow = window
        appWindow?.frame = window.bounds
    }
    
    @discardableResult
    override func start() -> UIViewController? {
        super.start()
        
        let navController = UINavigationController()
        navigationController = navController
        appWindow?.rootViewController = navigationController
        appWindow?.makeKeyAndVisible()
        return navigationController
    }
    
    override func navigate(to stepper: AppStep) -> StepAction {
        switch stepper {
        case .showListViewController:
            let vc = FoodListViewController()
            vc.coordinator = self
            return .push(vc)
        }
    }
}
