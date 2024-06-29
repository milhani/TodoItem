import SwiftUI


struct TodoCellView: View {

    let todoItem: TodoItem
    let action: () -> Void
    let radioButtonAction: () -> Void

    var body: some View {
       HStack(spacing: 12) {
            radioButton
                .padding(.trailing, 12)
                .onTapGesture {
                    radioButtonAction()
                }
            VStack(alignment: .leading) {
                HStack {
                    if let importanceImage {
                        importanceImage
                    }
                    textOfItem
                }
                if let deadline = todoItem.deadline {
                    deadlineLabel(deadline)
                }
            }
            Spacer()
            Image(.chevron)
                .padding(.trailing, 5)
            Rectangle()
                .fill(Color(hex: todoItem.color))
                .frame(width: 5)
                .padding(.vertical, -5)
        }
       .padding(.horizontal, 16)
       .padding(.vertical, 16)
    }

    private var textOfItem: some View {
        Text(todoItem.text)
            .font(.body)
            .foregroundStyle(todoItem.isDone ? Colors.labelTertiary : Colors.labelPrimary)
            .lineLimit(3)
            .truncationMode(.tail)
            .strikethrough(todoItem.isDone)
    }

    private var radioButton: Image {
        if todoItem.isDone {
            return Image(.radioButtonOn)
        }
        if todoItem.importance == .important {
            return Image(.radioButtonHighImportance)
        }
        return Image(.radioButtonOff)
    }

    private var importanceImage: Image? {
        switch todoItem.importance {
        case .low:
            Image(.importanceLow)
        case .normal:
            nil
        case .important:
            Image(.importanceHigh)
        }
    }

    private func deadlineLabel(_ deadline: Date) -> some View {
        HStack {
            Image(.calendar)
                .foregroundStyle(Colors.labelTertiary)
            Text(deadline.formatted(.dateTime.day().month().year()))
                .foregroundColor(Colors.labelTertiary)
                .font(.subheadline)
        }
    }

}

