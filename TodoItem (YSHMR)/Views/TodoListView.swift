import SwiftUI


struct TodoListView: View {

    @StateObject var viewModel: TodoListViewModel
    @FocusState private var isOn
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Мои дела")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    NavigationLink {
                        let calendarView = CalendarViewControllerRepresentable(viewModel: viewModel)
                        calendarView
                            .ignoresSafeArea()
                    } label: {
                        Image(systemName: "calendar")
                            .font(.largeTitle)
                            .foregroundColor(Colors.primaryBlue)
                    }
                    .ignoresSafeArea(.container)
                    .foregroundColor(.black)
                    
                }
                .padding(.bottom, 0)
                .padding(.top, 16)
                .padding(.horizontal, 25)
                List {
                    Section {
                        ForEach(viewModel.tasks) { todoItem in
                            TodoCellView(
                                todoItem: todoItem,
                                action: {
                                    viewModel.selectedItem = todoItem
                                    viewModel.todoViewPresented = true
                                },
                                radioButtonAction: {
                                    viewModel.toggleDone(todoItem)
                                }
                            )
                            .swipeActions(edge: .leading) {
                                Button(role: .cancel) { viewModel.toggleDone(todoItem) }
                            label: {
                                if todoItem.isDone {
                                    Label("Невыполнено", systemImage: "x.circle.fill").tint(Colors.primaryRed)
                                } else {
                                    Label("Выполнено", systemImage: "checkmark.circle.fill").tint(Colors.primaryGreen)
                                }
                            }
                                
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.delete(todoItem)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                                .tint(Colors.primaryRed)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    viewModel.selectedItem = todoItem
                                    viewModel.todoViewPresented = true
                                } label: {
                                    Label("Информация", systemImage: "info.circle.fill")
                                }
                                .tint(Colors.primaryLightGray)
                            }
                        }
                        newTodoItemView
                    } header: { headerView }
                        .listRowBackground(Colors.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("")
                .navigationBarHidden(true)
                .safeAreaInset(edge: .bottom) {
                    floatingButton
                }
                .sheet(isPresented: $viewModel.todoViewPresented) {
                    
                    TodoItemView (
                        viewModel: TodoItemViewModel(
                            todoItem: viewModel.openedItem, connection: viewModel.connection
                        )
                    )
                }
            }
            .background(Colors.backgroundPrimary)
        }
    }

    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            viewModel.checkItems()
            print(viewModel.$isUpdateCalendar)
        }){
            Text("back")
                }
    }

    private var newTodoItemView: some View {
        TextField(
            "",
            text: $viewModel.newTodo,
            prompt: Text("Новое").foregroundStyle(Colors.labelTertiary)
        )
        .listRowInsets(EdgeInsets(top: 16, leading: 60, bottom: 16, trailing: 16))
        .focused($isOn)
        .font(.body)
        .foregroundStyle(Colors.labelPrimary)
        .onSubmit {
            isOn = false
            if !viewModel.newTodo.isEmpty {
                viewModel.addItem(TodoItem(id: nil, text: viewModel.newTodo, isDone: nil, color: nil))
                viewModel.newTodo = ""
                isOn = true
            }
        }
    }

    private var floatingButton: some View {
        Button {
            viewModel.todoViewPresented.toggle()
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .foregroundStyle(Colors.primaryWhite, Colors.primaryBlue)
                .frame(width: 44, height: 44, alignment: .center)
                .padding(.vertical, 10)
        }
    }
    
    private var calenderButton: some View {
        Button {
            print("")
        } label: {
            Image(systemName: "calendar")
                .resizable()
                .foregroundStyle(Colors.primaryGray)
                .frame(width: 44, height: 44, alignment: .center)
                .padding(.vertical, 10)
        }
    }

    private var headerView: some View {
        HStack {
            Text("Выполнено — \(viewModel.doneCounter)")
                .foregroundStyle(Colors.labelTertiary)
                .font(.subheadline)
            Spacer()
            menu
        }
        .textCase(.none)
        .padding(.vertical, 6)
        .padding(.horizontal, -10)
    }

    private var menu: some View {
        Menu {
            Section {
                Button {
                    viewModel.toggleShowCompleted()
                } label: {
                    Label(
                        viewModel.chosenSorting ? "Скрыть" : "Показать",
                        systemImage: viewModel.chosenSorting ? "eye.slash" : "eye"
                    )
                }
            }
            Section {
                Button {
                    viewModel.changeImportance()
                } label: {
                    Label(
                        viewModel.sortType.rawValue,
                        systemImage: "arrow.up.arrow.down"
                    )
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .resizable()
                .foregroundStyle(Colors.labelPrimary, Colors.primaryBlue)
                .frame(width: 20, height: 20, alignment: .center)
                
        }
    }

}

