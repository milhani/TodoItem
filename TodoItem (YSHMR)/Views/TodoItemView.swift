import SwiftUI


struct TodoItemView: View {
    @StateObject var viewModel: TodoItemViewModel
    @State private var showDatePicker = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    newEventTextField
                }
                Section {
                    importanceField
                    colorField
                    deadlineField
                    
                    if showDatePicker {
                        datePicker
                    }
                }
                Section {
                    deleteButton
                }
                .listRowBackground(Colors.backgroundSecondary)
                .listRowSeparatorTint(Colors.primarySeparator)
                .listRowSpacing(16)
            }
                .background(Colors.backgroundPrimary)
                .navigationTitle("Дело")
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: { dismiss() }, label: {
                            Text("Отменить")
                                .font(.headline)
                                .foregroundStyle(Colors.primaryBlue)
                        })
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewModel.saveItem()
                            dismiss()
                        }, label: {
                            Text("Сохранить")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(!viewModel.text.isEmpty ? Colors.primaryBlue : Colors.labelTertiary)
                            
                            
                        })
                        .disabled(viewModel.text.isEmpty)
                    }
                }
        }
    }
    
    private var newEventTextField: some View {
        HStack {
            TextField(
                "",
                text: $viewModel.text,
                prompt: Text("Что надо сделать?").foregroundStyle(Colors.labelTertiary),
                axis: .vertical
            )
                .frame(minHeight: 120, alignment: .topLeading)
                .font(.body)
                .foregroundStyle(Colors.labelPrimary)
            Color(viewModel.color)
                .frame(width: 5)
                .cornerRadius(2.5)
                .padding(.vertical, 0)
        }
    }
        
    private var importanceField: some View {
        HStack {
            Text("Важность")
                .font(.body)
                .foregroundStyle(Colors.labelPrimary)
            Spacer()
            Picker("", selection: $viewModel.importance) {
                ForEach(Importance.allCases) { $0.symbol }
            }
            .pickerStyle(.segmented)
            .backgroundStyle(Colors.overlay)
            .padding(.vertical, 10)
            .scaledToFit()
        }
    }
    
    private var colorField: some View {
        VStack {
            HStack {
                Text("Цвет")
                Spacer(minLength: 1)
                Text("#" + String(format: "%06X", (viewModel.color.rgbColor)))
                }
            Spacer()
            ColorPickerView(viewModel: viewModel)
            }
    }
    
    private var deadlineField: some View {
        VStack {
            Toggle(isOn: $viewModel.isDeadlineEnabled) {
                Text("Сделать до")
                    .font(.body)
                    .foregroundStyle(Colors.labelPrimary)
                .onChange(of: viewModel.isDeadlineEnabled) { newValue in
                    showDatePicker = !newValue ? false : true
                }
            }
            if viewModel.isDeadlineEnabled {
                HStack {
                    Text(
                        viewModel.selectedDeadline.formatted(.dateTime.day().month().year())
                    )
                    .font(.footnote)
                    .foregroundStyle(Colors.primaryBlue)
                    .fontWeight(.bold)
                    .onTapGesture {
                        withAnimation {
                            showDatePicker.toggle()
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var datePicker: some View {
        DatePicker(
            "",
            selection: $viewModel.selectedDeadline,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .onChange(of: viewModel.selectedDeadline) { newValue in
            showDatePicker = false
        }
    }
    
    private var deleteButton: some View {
        Button {
            viewModel.removeItem()
            dismiss()
        } label: {
            Text("Удалить")
                .frame(maxWidth: .infinity)
                .frame(minHeight: 40)
                .font(.body)
                .foregroundStyle(viewModel.isNew ? Colors.labelTertiary : Colors.primaryRed)
        }
        .disabled(viewModel.isNew)
    }
}
