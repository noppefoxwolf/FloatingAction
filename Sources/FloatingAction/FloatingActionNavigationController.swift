import UIKit

@MainActor
open class FloatingActionNavigationController: UINavigationController, FloatingItemChangeObserver {
    private struct ActiveButton {
        let button: FloatingActionButton
        let item: FloatingActionItem
    }

    private let containerView = FloatingActionContainerView()
    private var activeButton: ActiveButton?
    private var buttonsByIdentifier: [String: FloatingActionButton] = [:]
    private weak var currentFloatingItem: FloatingItem?

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if let topViewController {
            setCurrentItem(to: topViewController)
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(containerView)
    }

    open func handleDidShow(_ viewController: UIViewController, animated: Bool) {
        // Keep supporting clients that only forward didShow. Clients that also
        // forward willShow start the button transition alongside UIKit's bar animation.
        setCurrentItem(floatingItem(for: viewController), animated: animated)
        removeItemsForViewControllersOutsideStack()
    }

    open func handleWillShow(_ viewController: UIViewController, animated: Bool) {
        guard animated, let coordinator = transitionCoordinator else {
            setCurrentItem(floatingItem(for: viewController), animated: false)
            return
        }

        setCurrentItem(floatingItem(for: viewController), alongside: coordinator)
    }

    func floatingItem(for viewController: UIViewController) -> FloatingItem {
        viewController.floatingItem
    }

    func floatingItemDidChangeTrailingItem(_ item: FloatingItem) {
        updateIfCurrent(item)
    }

    private func updateIfCurrent(_ item: FloatingItem) {
        guard currentFloatingItem === item else { return }
        render(item)
    }

    private func setCurrentItem(to viewController: UIViewController) {
        setCurrentItem(floatingItem(for: viewController))
    }

    private func setCurrentItem(_ item: FloatingItem, animated: Bool = false) {
        currentFloatingItem?.changeObserver = nil
        currentFloatingItem = item
        item.changeObserver = self
        render(item, animated: animated)
    }

    private func setCurrentItem(
        _ item: FloatingItem,
        alongside coordinator: UIViewControllerTransitionCoordinator
    ) {
        currentFloatingItem?.changeObserver = nil
        currentFloatingItem = item
        item.changeObserver = self
        render(item, alongside: coordinator)
    }

    private func render(_ item: FloatingItem, animated: Bool = false) {
        let sourceButton = activeButton?.button

        guard let destinationItem = item.trailingItem else {
            activeButton = nil
            remove(sourceButton, animated: animated)
            return
        }

        let button = makeButton(for: destinationItem, animated: animated && sourceButton != nil)
        if sourceButton !== button {
            button.alpha = 1
            button.transform = .identity
            if animated {
                button.alpha = 0
                button.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
            }
        }
        button.isUserInteractionEnabled = true
        activeButton = ActiveButton(button: button, item: destinationItem)

        guard sourceButton !== button else { return }
        sourceButton?.isUserInteractionEnabled = false

        guard animated else {
            sourceButton?.removeFromSuperview()
            return
        }

        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut]
        ) {
            button.alpha = 1
            button.transform = .identity
            sourceButton?.alpha = 0
            sourceButton?.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        } completion: { [weak self, weak sourceButton] _ in
            guard let self, let sourceButton, self.activeButton?.button !== sourceButton else { return }
            sourceButton.removeFromSuperview()
        }
    }

    private func render(_ item: FloatingItem, alongside coordinator: UIViewControllerTransitionCoordinator) {
        let sourceActiveButton = activeButton
        let sourceButton = sourceActiveButton?.button

        guard let destinationItem = item.trailingItem else {
            activeButton = nil
            guard let sourceButton else { return }
            sourceButton.isUserInteractionEnabled = false
            let didSchedule = coordinator.animate(alongsideTransition: { _ in
                sourceButton.alpha = 0
                sourceButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
            }, completion: { [weak self, weak sourceButton] context in
                guard let self, let sourceButton else { return }
                if context.isCancelled {
                    sourceButton.alpha = 1
                    sourceButton.transform = .identity
                    sourceButton.isUserInteractionEnabled = true
                    self.activeButton = sourceActiveButton
                    if let identifier = sourceActiveButton?.item.identifier {
                        self.buttonsByIdentifier[identifier] = sourceButton
                    }
                } else if self.activeButton?.button !== sourceButton {
                    sourceButton.removeFromSuperview()
                }
            })
            if !didSchedule {
                sourceButton.removeFromSuperview()
            }
            return
        }

        let button = makeButton(for: destinationItem, animated: false)
        if sourceButton !== button {
            button.alpha = 0
            button.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }
        button.isUserInteractionEnabled = true
        activeButton = ActiveButton(button: button, item: destinationItem)

        guard sourceButton !== button else { return }
        sourceButton?.isUserInteractionEnabled = false
        let didSchedule = coordinator.animate(alongsideTransition: { _ in
            button.alpha = 1
            button.transform = .identity
            sourceButton?.alpha = 0
            sourceButton?.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }, completion: { [weak self, weak sourceButton] context in
            guard let self else { return }
            if context.isCancelled {
                sourceButton?.alpha = 1
                sourceButton?.transform = .identity
                sourceButton?.isUserInteractionEnabled = true
                button.removeFromSuperview()
                self.activeButton = sourceActiveButton
                if let sourceButton, let identifier = sourceActiveButton?.item.identifier {
                    self.buttonsByIdentifier[identifier] = sourceButton
                }
            } else if let sourceButton, self.activeButton?.button !== sourceButton {
                sourceButton.removeFromSuperview()
            }
        })
        if !didSchedule {
            button.alpha = 1
            button.transform = .identity
            sourceButton?.removeFromSuperview()
        }
    }

    private func remove(_ button: FloatingActionButton?, animated: Bool) {
        guard let button else { return }
        button.isUserInteractionEnabled = false

        guard animated else {
            button.removeFromSuperview()
            return
        }

        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut]
        ) {
            button.alpha = 0
            button.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        } completion: { [weak self, weak button] _ in
            guard let button, self?.activeButton?.button !== button else { return }
            button.removeFromSuperview()
        }
    }

    private func makeButton(for item: FloatingActionItem, animated: Bool) -> FloatingActionButton {
        let button: FloatingActionButton
        if let activeButton, activeButton.item === item {
            button = activeButton.button
        } else if let identifier = item.identifier,
                  let existingButton = buttonsByIdentifier[identifier],
                  existingButton !== activeButton?.button {
            button = existingButton
        } else {
            button = FloatingActionButton()
            if let identifier = item.identifier {
                buttonsByIdentifier[identifier] = button
            }
        }
        button.install(in: containerView)
        button.bind(to: item, animated: animated)
        containerView.layoutIfNeeded()
        return button
    }

    private func removeItemsForViewControllersOutsideStack() {
        let retainedButtonIdentifiers = Set(
            viewControllers
                .compactMap { FloatingItemStorage.existingItem(for: $0)?.trailingItem?.identifier }
        )
        buttonsByIdentifier = buttonsByIdentifier.filter { retainedButtonIdentifiers.contains($0.key) }
    }
}
