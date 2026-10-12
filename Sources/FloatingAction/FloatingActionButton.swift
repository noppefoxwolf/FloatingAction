import UIKit

@MainActor
final class FloatingActionButton: UIButton, FloatingActionItemChangeObserver {
    private(set) weak var item: FloatingActionItem?
    private var actionIdentifier: UIAction.Identifier?

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            configuration = .prominentGlass()
        } else {
            configuration = .borderedProminent()
            configuration?.cornerStyle = .capsule
        }
        configuration?.buttonSize = .large
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ item: FloatingActionItem) {
        var buttonConfiguration: UIButton.Configuration
        if #available(iOS 26.0, *) {
            switch item.style {
            case .plain:
                buttonConfiguration = .glass()
            case .prominent:
                buttonConfiguration = .prominentGlass()
            }
        } else {
            switch item.style {
            case .plain:
                buttonConfiguration = .bordered()
            case .prominent:
                buttonConfiguration = .borderedProminent()
            }
            buttonConfiguration.cornerStyle = .capsule
        }
        buttonConfiguration.buttonSize = .large
        buttonConfiguration.image = item.image
        if item.style == .plain, let tintColor = item.tintColor {
            buttonConfiguration.baseForegroundColor = tintColor
            buttonConfiguration.image = item.image?.withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }
        if let actionIdentifier {
            removeAction(identifiedBy: actionIdentifier, for: .primaryActionTriggered)
        }
        if let action = item.action {
            addAction(action, for: .primaryActionTriggered)
            actionIdentifier = action.identifier
        } else {
            actionIdentifier = nil
        }
        menu = item.menu
        showsMenuAsPrimaryAction = item.menu != nil && item.action == nil
        buttonConfiguration.title = item.title
        buttonConfiguration.imagePadding = 8
        UIView.performWithoutAnimation {
            self.configuration = buttonConfiguration
            self.tintColor = item.style == .plain ? nil : item.tintColor
            self.accessibilityLabel = item.title ?? item.action?.title
            self.isHidden = item.isHidden
            self.layoutIfNeeded()
        }
    }

    func bind(to item: FloatingActionItem, animated: Bool = false) {
        guard self.item !== item else { return }
        self.item?.changeObserver = nil
        self.item = item
        item.changeObserver = self
        if animated {
            UIView.transition(
                with: self,
                duration: 0.22,
                options: [.transitionCrossDissolve, .beginFromCurrentState, .allowAnimatedContent]
            ) {
                self.apply(item)
            }
        } else {
            apply(item)
        }
    }

    func install(in container: FloatingActionContainerView) {
        container.addButton(self)
    }

    func floatingActionItemContentDidChange(_ item: FloatingActionItem) {
        updateIfCurrent(item)
    }

    func floatingActionItemAppearanceDidChange(_ item: FloatingActionItem) {
        updateIfCurrent(item)
    }

    func floatingActionItemVisibilityDidChange(_ item: FloatingActionItem) {
        updateIfCurrent(item)
    }

    private func updateIfCurrent(_ item: FloatingActionItem) {
        guard item === self.item else { return }
        apply(item)
    }
}
