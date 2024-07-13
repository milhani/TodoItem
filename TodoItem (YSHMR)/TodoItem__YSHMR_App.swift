import SwiftUI
import MyLibrary

@main
struct TodoItem__YSHMR_App: App {
    private let todoListViewModel = TodoListViewModel(fileCache: FileCache())
    
    var body: some Scene {
        WindowGroup {
            TodoListView(viewModel: todoListViewModel)
        }
    }
}
