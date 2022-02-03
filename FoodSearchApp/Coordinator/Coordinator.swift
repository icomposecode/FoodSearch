import Combine
import UIKit

enum Step {
    case push(UIViewController)
    case none
}

enum StepAction {
    case push(UIViewController)
    case none
}

class Coordinator<Step> {
    weak var navigationController: UINavigationController?
    
    var bag = Set<AnyCancellable>()
    @Published var step: Step?
    
    
    func navigate(to stepper: Step) -> StepAction {
        return .none
    }
    
    func navigate(action: StepAction) {
        switch action {
        case let .push(viewController):
            navigationController?.pushViewController(viewController, animated: true)
        case .none:
            break
        }
    }
    
    @discardableResult
    func start() -> UIViewController? {
        $step
            .compactMap{ $0 }
            .sink {[weak self] step in
                guard let self = self else { return }
            self.navigate(action: self.navigate(to: step))
        }.store(in: &bag)
        return navigationController
    }
}
