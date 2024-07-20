import SwiftUI
import MyLibrary

@main
struct TodoItem__YSHMR_App: App {
    private let todoListViewModel = TodoListViewModel(connection: ServerViewConnection(fileCache: FileCache<TodoItem>(filename: "items.json", fileFormat: .json), networkService: DefaultNetworkingService.shared))
    
    var body: some Scene {
        WindowGroup {
            TodoListView(viewModel: todoListViewModel)
                .onAppear(perform: initLog)
        }
    }
}
