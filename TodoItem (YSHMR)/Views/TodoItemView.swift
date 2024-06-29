import SwiftUI


struct TodoItemView: View {
    
    @StateObject var viewModel: TodoItemViewModel
    @FocusState private var isOn
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedColor = Colors.primaryGreen
    @State private var brightness: Double = 0.5

    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section {
                        newEventTextView
                    }
                    Section {
                        importanceField
                        colorField
                        deadlineField
                        if viewModel.isDeadlineEnabled {
                            datePicker
                        }
                    }
                    Section {
                        deleteButton
                    }
                }
                .listRowBackground(Colors.backgroundSecondary)
                .listRowSeparatorTint(Colors.primarySeparator)
            }
            .background(Colors.backgroundPrimary)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(16)
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Отмена")
                            .font(.body)
                            .foregroundStyle(Colors.primaryBlue)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.saveItem()
                        dismiss()
                    } label: {
                        Text("Сохранить")
                            .font(.body)
                            .foregroundStyle(!viewModel.text.isEmpty ? Colors.primaryBlue : Colors.labelTertiary)
                            .bold()
                    }
                    .disabled(viewModel.text.isEmpty)
                }
            }
        }
    }

    @available(iOS 17.0, *)
    private var newEventTextView: some View {
        TextField(
            "",
            text: $viewModel.text,
            prompt: Text("Что надо сделать?").foregroundStyle(Colors.labelTertiary),
            axis: .vertical
        )
        .frame(minHeight: 120, alignment: .topLeading)
        .focused($isOn)
        .font(.body)
        .foregroundStyle(Colors.labelPrimary)
        .overlay(
            HStack {
                Spacer()
                Rectangle()
                    .fill(viewModel.color)
                    .frame(width: 5)
                    .padding(.trailing, -5)
                    .padding(.vertical, -12)
            }
        )
    }
    
    private var importanceField: some View {
        HStack {
            Text("Важность")
                .font(.body)
                .foregroundStyle(Colors.labelPrimary)
                .truncationMode(.tail)
            Spacer()
            Picker("", selection: $viewModel.importance) {
                ForEach(Importance.allCases) { $0.symbol }
            }
            .frame(maxWidth: 150)
            .pickerStyle(.segmented)
            .backgroundStyle(Colors.overlay)
        }
    }
    
    private var deadlineField: some View {
        VStack {
            Toggle(isOn: $viewModel.isDeadlineEnabled.animation()) {
                Text("Сделать до")
                    .font(.body)
                    .foregroundStyle(Colors.labelPrimary)
                    .truncationMode(.tail)
            }
            if viewModel.isDeadlineEnabled {
                HStack {
                    Text(
                        viewModel.selectedDeadline.formatted(.dateTime.day().month().year())
                    )
                    .font(.footnote)
                    .foregroundStyle(Colors.primaryBlue)
                    Spacer()
                }
            }
        }
    }
    
    private var colorField: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(selectedColor.adjust(brightness: brightness))
                    .frame(width: 44, height: 44)
                    .padding(.leading, 8)
                Spacer(minLength: 1)
                Text("#" + String(format: "%06X", (selectedColor.rgbColor)))
                    .padding()
                Spacer()
                ColorPicker("", selection: $selectedColor)
                    .padding()
            }

            Slider(value: $brightness, in: 0.0...1.0)
                .padding()
                
        }
    }
    
    private var datePicker: some View {
        DatePicker(
            "",
            selection: $viewModel.selectedDeadline,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
    }
    
    private var deleteButton: some View {
        Button {
            viewModel.removeItem()
            dismiss()
        } label: {
            Text("Удалить")
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(viewModel.isNew ? Colors.labelTertiary : Colors.primaryRed)
        }
        .disabled(viewModel.isNew)
    }
}
