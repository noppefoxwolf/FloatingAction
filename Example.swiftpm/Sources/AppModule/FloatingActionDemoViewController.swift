import UIKit
import FloatingAction

@MainActor
final class FloatingActionDemoViewController: UIViewController {
    private let level: Int
    private let floatingActionStyle: FloatingActionItem.Style?

    init(level: Int, floatingActionStyle: FloatingActionItem.Style? = .prominent, title: String? = nil) {
        self.level = level
        self.floatingActionStyle = floatingActionStyle
        super.init(nibName: nil, bundle: nil)
        self.title = title ?? "Screen \(level)"
        configureFloatingItem()
        configureRightBarButtonItem()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureContent()   
    }

    private func configureFloatingItem() {
        guard let floatingActionStyle else { return }
        let actionTitle = level == 0 ? "Create" : "Save on screen \(level)"
        let image = UIImage(systemName: level == 0 ? "plus" : "square.and.arrow.down")
        let action = UIAction(title: actionTitle, image: image) { [weak self] _ in
            self?.performFloatingAction()
        }
        let menu = UIMenu(children: [
            UIAction(title: "Complete", image: UIImage(systemName: "checkmark")) { [weak self] _ in
                self?.performFloatingAction()
            }
        ])
        let item = FloatingActionItem(
            identifier: "floating-action",
            tintColor: floatingActionTintColor,
            style: floatingActionStyle,
            action: action,
            menu: menu
        )
        item.title = nil
        floatingItem.trailingItem = item
    }

    // Use this instead of configureFloatingItem() to show the action in the navigation bar.
    private func configureRightBarButtonItem() {
        guard let floatingActionStyle else { return }

        let actionTitle = level == 0 ? "Create" : "Save on screen \(level)"
        let image = UIImage(systemName: level == 0 ? "plus" : "square.and.arrow.down")
        let action = UIAction(title: actionTitle, image: image) { [weak self] _ in
            self?.performFloatingAction()
        }
        let menu = UIMenu(children: [
            UIAction(title: "Complete", image: UIImage(systemName: "checkmark")) { [weak self] _ in
                self?.performFloatingAction()
            }
        ])

        let rightBarButtonItem = UIBarButtonItem(
            title: actionTitle,
            image: image,
            primaryAction: action,
            menu: menu
        )
        rightBarButtonItem.tintColor = floatingActionTintColor
        rightBarButtonItem.style = floatingActionStyle.barButtonItemStyle
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private var floatingActionTintColor: UIColor {
        level == 0 ? .systemBlue : .systemGreen
    }

    private func configureContent() {
        let titleLabel = UILabel()
        titleLabel.text = "The floating action lives in the navigation controller."
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .title3)

        let detailLabel = UILabel()
        detailLabel.text = "Push a screen with either glass style, or without a floating action. Update it here to see the observer flow."
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.textColor = .secondaryLabel

        let pushPlainButton = UIButton(type: .system)
        pushPlainButton.configuration = .bordered()
        pushPlainButton.configuration?.title = "Push with Plain Style"
        pushPlainButton.addAction(
            UIAction(title: "Push with Plain Style", image: UIImage(systemName: "arrow.right")) { [weak self] _ in
                self?.pushNext(floatingActionStyle: .plain)
            },
            for: .touchUpInside
        )

        let pushProminentButton = UIButton(type: .system)
        pushProminentButton.configuration = .bordered()
        pushProminentButton.configuration?.title = "Push with Prominent Style"
        pushProminentButton.addAction(
            UIAction(title: "Push with Prominent Style", image: UIImage(systemName: "arrow.right")) { [weak self] _ in
                self?.pushNext(floatingActionStyle: .prominent)
            },
            for: .touchUpInside
        )

        let pushWithoutActionButton = UIButton(type: .system)
        pushWithoutActionButton.configuration = .bordered()
        pushWithoutActionButton.configuration?.title = "Push without Floating Action"
        pushWithoutActionButton.addAction(
            UIAction(title: "Push without Floating Action", image: UIImage(systemName: "minus.circle")) { [weak self] _ in
                self?.pushNext(floatingActionStyle: nil)
            },
            for: .touchUpInside
        )

        let updateButton = UIButton(type: .system)
        updateButton.configuration = .borderedProminent()
        updateButton.configuration?.title = "Update floating action"
        updateButton.addTarget(self, action: #selector(updateFloatingActionButton), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            detailLabel,
            pushPlainButton,
            pushProminentButton,
            pushWithoutActionButton,
            updateButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    @objc private func updateFloatingActionButton() {
        guard let item = currentFloatingActionItem else { return }
        item.image = UIImage(systemName: "checkmark")
        item.tintColor = .systemPurple
    }

    private func performFloatingAction() {
        guard let item = currentFloatingActionItem else { return }
        item.image = UIImage(systemName: "checkmark")
    }

    private var currentFloatingActionItem: FloatingActionItem? {
        floatingItem.trailingItem
    }

    private func pushNext(floatingActionStyle: FloatingActionItem.Style?) {
        navigationController?.pushViewController(
            FloatingActionDemoViewController(level: level + 1, floatingActionStyle: floatingActionStyle),
            animated: true
        )
    }
}

private extension FloatingActionItem.Style {
    var barButtonItemStyle: UIBarButtonItem.Style {
        switch self {
        case .plain:
            .plain
        case .prominent:
            if #available(iOS 26.0, *) {
                .prominent
            } else {
                .plain
            }
        }
    }
}
