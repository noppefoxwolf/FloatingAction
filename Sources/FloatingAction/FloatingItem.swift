import UIKit

@MainActor
enum FloatingItemStorage {
    private static let itemsByViewController = NSMapTable<UIViewController, FloatingItem>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )

    static func item(for viewController: UIViewController) -> FloatingItem {
        if let item = itemsByViewController.object(forKey: viewController) {
            return item
        }

        let item = FloatingItem()
        itemsByViewController.setObject(item, forKey: viewController)
        return item
    }

    static func existingItem(for viewController: UIViewController) -> FloatingItem? {
        itemsByViewController.object(forKey: viewController)
    }
}

@MainActor
protocol FloatingItemChangeObserver: AnyObject {
    func floatingItemDidChangeTrailingItem(_ item: FloatingItem)
}

@MainActor
public final class FloatingItem {
    weak var changeObserver: FloatingItemChangeObserver?

    public var trailingItem: FloatingActionItem? {
        didSet {
            guard oldValue !== trailingItem else { return }
            changeObserver?.floatingItemDidChangeTrailingItem(self)
        }
    }

    public init(trailingItem: FloatingActionItem? = nil) {
        self.trailingItem = trailingItem
    }
}

@MainActor
public extension UIViewController {
    var floatingItem: FloatingItem {
        FloatingItemStorage.item(for: self)
    }
}
