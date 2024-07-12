import UIKit


final class ItemCell: UITableViewCell {
    static let identifier = String(describing: ItemCell.self)

    private let categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textItemLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let hStack = UIStackView(arrangedSubviews: [textItemLabel, categoryImageView])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .fill
        hStack.spacing = 16
        hStack.translatesAutoresizingMaskIntoConstraints = false
        return hStack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(contentStackView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTextLabel(text: String, isStrikethrough: Bool) {
        textItemLabel.attributedText = NSAttributedString(string: text)
        textItemLabel.textColor = isStrikethrough ? UIColor.tertiaryLabel: UIColor.labelPrimary
        textItemLabel.strikeThrough(isStrikethrough)
    }
    
    func setCategoryImage(color: UIColor) {
        categoryImageView.tintColor = color
    }
    
    private func setConstraints() {
        let contentHStackViewWidthAnchor = contentStackView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor)
        contentHStackViewWidthAnchor.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.layoutMarginsGuide.topAnchor, multiplier: 1.0),
            contentHStackViewWidthAnchor,
            contentStackView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: contentStackView.bottomAnchor, multiplier: 1.0)
        ])
    }
}

extension ItemCell: CellConfigurable {
    func configure(with todoItem: TodoItem) {
        if todoItem.isDone {
            setTextLabel(text: todoItem.text, isStrikethrough: todoItem.isDone)
        } else {
            setTextLabel(text: todoItem.text, isStrikethrough: todoItem.isDone)
        }

        if let color = UIColor(hex: todoItem.category.color) {
            setCategoryImage(color: color)
        } else {
            setCategoryImage(color: UIColor(resource: .white))
        }
    }
}
