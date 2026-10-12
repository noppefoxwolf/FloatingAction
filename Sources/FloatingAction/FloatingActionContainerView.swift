import UIKit

@MainActor
final class FloatingActionContainerView: UIView {
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addButton(_ button: FloatingActionButton) {
        guard button.superview !== self else { return }
        addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -12),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        subviews.reversed().contains { view in
            guard let button = view as? FloatingActionButton,
                  button.isUserInteractionEnabled,
                  !button.isHidden,
                  button.alpha > 0.01 else { return false }
            return button.frame.contains(point)
        }
    }
}
