import UIKit


final class CalendarView: UIView {

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(
            DateCell.self,
            forCellWithReuseIdentifier:
                DateCell.identifier
        )
        collectionView.backgroundColor = UIColor(resource: .backPrimary)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(
            ItemCell.self,
            forCellReuseIdentifier: ItemCell.identifier
        )
        tableView.backgroundColor = UIColor(resource: .backPrimary)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var separatorViewFirst: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .labelTertiary)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var separatorViewSecond: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .labelTertiary)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "Мои дела"
        return label
    }()
    
    var button: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame.size.width = 44
        button.frame.size.height = 44
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(resource: .backPrimary)
        addSubview(separatorViewFirst)
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(separatorViewSecond)
        addSubview(tableView)
        addSubview(button)
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            section.orthogonalScrollingBehavior = .continuous
            
            return section
        }
        
        return layout
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            separatorViewFirst.topAnchor.constraint(equalTo: topAnchor, constant: 43),
            separatorViewFirst.widthAnchor.constraint(equalTo: widthAnchor),
            separatorViewFirst.heightAnchor.constraint(equalToConstant: 1),
            separatorViewFirst.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 80),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separatorViewSecond.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            separatorViewSecond.widthAnchor.constraint(equalTo: widthAnchor),
            separatorViewSecond.heightAnchor.constraint(equalToConstant: 1),
            separatorViewSecond.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: separatorViewSecond.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    
}
