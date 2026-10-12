@testable import FloatingAction
import Testing
import UIKit

@MainActor
struct FloatingActionNavigationControllerTests {
    @Test func repeatedDidShowKeepsCurrentButton() throws {
        guard #available(iOS 26.0, *) else { return }

        let sourceViewController = UIViewController()
        let navigationController = FloatingActionNavigationController(
            rootViewController: sourceViewController
        )
        sourceViewController.floatingItem.trailingItem = FloatingActionItem(
            identifier: "source-action",
            title: "Source action"
        )

        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.view.layoutIfNeeded()
        navigationController.handleDidShow(sourceViewController, animated: false)
        let sourceButton = try #require(buttons(in: navigationController.view).first {
            $0.accessibilityLabel == "Source action"
        })

        navigationController.handleDidShow(sourceViewController, animated: true)

        #expect(buttons(in: navigationController.view).contains { $0 === sourceButton })
        window.isHidden = true
    }

    @Test func trailingItemCanBeReplacedOrCleared() {
        let rootViewController = UIViewController()
        let navigationController = FloatingActionNavigationController(rootViewController: rootViewController)
        let firstItem = FloatingActionItem(identifier: "first", title: "First")
        let floatingItem = rootViewController.floatingItem

        floatingItem.trailingItem = firstItem
        #expect(floatingItem.trailingItem === firstItem)

        let secondItem = FloatingActionItem(identifier: "second", title: "Second")
        floatingItem.trailingItem = secondItem
        #expect(floatingItem.trailingItem === secondItem)

        floatingItem.trailingItem = nil
        #expect(floatingItem.trailingItem == nil)
        #expect(rootViewController.navigationController === navigationController)
    }

    @Test func trailingItemIsRenderedAsAButton() {
        let rootViewController = UIViewController()
        let navigationController = FloatingActionNavigationController(rootViewController: rootViewController)
        rootViewController.floatingItem.trailingItem = FloatingActionItem(
            identifier: "first",
            title: "First action"
        )

        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.view.layoutIfNeeded()
        navigationController.handleDidShow(rootViewController, animated: false)

        let labels = buttons(in: navigationController.view).compactMap(\.accessibilityLabel)
        #expect(labels == ["First action"])
        window.isHidden = true
    }

    private func buttons(in view: UIView) -> [UIButton] {
        view.subviews.flatMap { subview in
            (subview as? UIButton).map { [$0] } ?? buttons(in: subview)
        }
    }
}
