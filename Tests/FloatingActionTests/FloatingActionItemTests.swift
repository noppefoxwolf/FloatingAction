@testable import FloatingAction
import Testing
import UIKit

@MainActor
struct FloatingActionItemTests {
    @Test func primaryActionTakesPrecedenceOverBarButtonItemTitleAndImage() {
        let actionImage = UIImage(systemName: "bolt.fill")
        let itemImage = UIImage(systemName: "star.fill")
        let action = UIAction(title: "Action title", image: actionImage) { _ in }
        let barButtonItem = UIBarButtonItem(
            title: "Item title",
            image: itemImage,
            primaryAction: action,
            menu: nil
        )

        #expect(barButtonItem.title == action.title)
        #expect(barButtonItem.image === action.image)
    }

    @Test func primaryActionTakesPrecedenceOverFloatingActionItemTitleAndImage() {
        let actionImage = UIImage(systemName: "bolt.fill")
        let itemImage = UIImage(systemName: "star.fill")
        let action = UIAction(title: "Action title", image: actionImage) { _ in }
        let item = FloatingActionItem(
            title: "Item title",
            image: itemImage,
            action: action
        )
        let button = FloatingActionButton()

        button.apply(item)

        #expect(item.title == action.title)
        #expect(item.image === action.image)
        #expect(button.configuration?.title == action.title)
        #expect(button.configuration?.image === action.image)
    }
}
