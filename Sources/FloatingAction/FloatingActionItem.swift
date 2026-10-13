import UIKit

@MainActor
protocol FloatingActionItemChangeObserver: AnyObject {
    func floatingActionItemContentDidChange(_ item: FloatingActionItem)
    func floatingActionItemAppearanceDidChange(_ item: FloatingActionItem)
    func floatingActionItemVisibilityDidChange(_ item: FloatingActionItem)
}

@MainActor
public final class FloatingActionItem {
    public enum Style: Equatable {
        case plain
        case prominent
    }

    weak var changeObserver: FloatingActionItemChangeObserver?
    private var isContentChangeScheduled = false

    /// An identifier used to match this item with an item on another screen during navigation transitions.
    public var identifier: String?

    public var title: String? {
        didSet {
            guard oldValue != title else { return }
            notifyContentDidChange()
        }
    }

    public var image: UIImage? {
        didSet {
            guard oldValue !== image else { return }
            notifyContentDidChange()
        }
    }

    public var isHidden: Bool {
        didSet {
            guard oldValue != isHidden else { return }
            changeObserver?.floatingActionItemVisibilityDidChange(self)
        }
    }

    public var tintColor: UIColor? {
        didSet {
            switch (oldValue, tintColor) {
            case (nil, nil):
                return
            case let (oldColor?, newColor?) where oldColor.isEqual(newColor):
                return
            default:
                break
            }
            changeObserver?.floatingActionItemAppearanceDidChange(self)
        }
    }

    public var style: Style {
        didSet {
            guard oldValue != style else { return }
            changeObserver?.floatingActionItemAppearanceDidChange(self)
        }
    }

    public var action: UIAction? {
        didSet {
            if let action {
                title = action.title
                image = action.image
            }
            notifyContentDidChange()
        }
    }

    public var menu: UIMenu? {
        didSet {
            changeObserver?.floatingActionItemAppearanceDidChange(self)
        }
    }
    
    public init(
        identifier: String? = nil,
        title: String? = nil,
        image: UIImage? = nil,
        isHidden: Bool = false,
        tintColor: UIColor? = nil,
        style: Style = .prominent,
        action: UIAction? = nil,
        menu: UIMenu? = nil
    ) {
        self.identifier = identifier
        self.title = action == nil ? title : action?.title
        self.image = action == nil ? image : action?.image
        self.isHidden = isHidden
        self.tintColor = tintColor
        self.style = style
        self.action = action
        self.menu = menu
    }

    private func notifyContentDidChange() {
        guard !isContentChangeScheduled else { return }
        isContentChangeScheduled = true

        Task { @MainActor [weak self] in
            await Task.yield()
            guard let self else { return }
            self.isContentChangeScheduled = false
            self.changeObserver?.floatingActionItemContentDidChange(self)
        }
    }
}
