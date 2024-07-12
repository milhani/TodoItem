import SwiftUI


struct CalendarViewControllerRepresentable: UIViewControllerRepresentable {
    
    let viewModel: TodoListViewModel

    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        let viewController = CalendarViewController(todoListviewModel: viewModel)
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
