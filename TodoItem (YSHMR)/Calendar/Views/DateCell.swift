import UIKit


final class DateCell: UICollectionViewCell {
    static let identifier = String(describing: DateCell.self)

    private var dayLabel = UILabel()
    private var monthLabel = UILabel()
    
    private lazy var contentStackView: UIStackView = {
        if monthLabel.text == "" {
            let stack = UIStackView(arrangedSubviews: [dayLabel])
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.alignment = .center
            return stack
        }
        let stack = UIStackView(arrangedSubviews: [dayLabel, monthLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.masksToBounds = true
        contentView.addSubview(contentStackView)
        setSelectedCellView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDayLabel(text: String?) {
        dayLabel = customLabel(label: dayLabel, text: text)
        if dayLabel.text == "Другое" {
            dayLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    func setMonthLabel(text: String?) {
        monthLabel = customLabel(label: monthLabel, text: text)
    }
    
    private func customLabel(label: UILabel, text: String?) -> UILabel {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor(Colors.labelSecondary)
        label.text = text
        return label
    }
    
    private func setSelectedCellView() {
        let selectionView = UIView(frame: bounds)
        selectionView.layer.cornerRadius = 10
        selectionView.layer.borderColor = UIColor(Colors.labelSecondary).cgColor
        selectionView.layer.borderWidth = 2
        selectionView.backgroundColor = UIColor(Colors.overlay)
        selectedBackgroundView = selectionView
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
