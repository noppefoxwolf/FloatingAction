import SwiftUI
import UIKit

@main
struct FloatingActionDemoApp: App {
    var body: some Scene {
        WindowGroup {
            FloatingActionRootController()
                .ignoresSafeArea()
        }
    }
}

private struct FloatingActionRootController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> FloatingActionDemoTabBarController {
        FloatingActionDemoTabBarController()
    }

    func updateUIViewController(_ uiViewController: FloatingActionDemoTabBarController, context: Context) {}
}
