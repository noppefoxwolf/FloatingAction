import UIKit
import FloatingAction

@MainActor
final class FloatingActionDemoTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)

        let splitViewController = FloatingActionDemoSplitViewController()
        splitViewController.tabBarItem = UITabBarItem(
            title: "Actions",
            image: UIImage(systemName: "bolt.fill"),
            selectedImage: nil
        )
        viewControllers = [splitViewController]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
final class FloatingActionDemoNavigationController: FloatingActionNavigationController, UINavigationControllerDelegate {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        handleWillShow(viewController, animated: animated)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        handleDidShow(viewController, animated: animated)
    }
}

@MainActor
final class FloatingActionDemoSplitViewController: UISplitViewController {
    private weak var primaryNavigationController: FloatingActionDemoNavigationController?

    var showsOnlySecondaryFloatingAction = true {
        didSet {
            updatePrimaryFloatingActionVisibility()
        }
    }

    init() {
        super.init(style: .doubleColumn)
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .tile

        let primaryNavigationController = FloatingActionDemoNavigationController(
            rootViewController: FloatingActionDemoViewController(level: 0, floatingActionStyle: .prominent, title: "Floating Actions")
        )
        let secondaryNavigationController = FloatingActionDemoNavigationController(
            rootViewController: FloatingActionDemoViewController(level: 0, floatingActionStyle: .prominent, title: "Trailing")
        )
        self.primaryNavigationController = primaryNavigationController
        setViewController(primaryNavigationController, for: .primary)
        setViewController(secondaryNavigationController, for: .secondary)
        updatePrimaryFloatingActionVisibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePrimaryFloatingActionVisibility()
    }

    private func updatePrimaryFloatingActionVisibility() {
        primaryNavigationController?.showsFloatingAction = !showsOnlySecondaryFloatingAction || isCollapsed
    }
}
