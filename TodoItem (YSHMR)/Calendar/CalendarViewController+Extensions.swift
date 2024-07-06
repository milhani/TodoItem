import UIKit
import SwiftUI


protocol CellConfigurable {
    func configure(with todoItem: TodoItem)
}
protocol TodoListViewControllerDelegate: AnyObject {
    func didUpdateTodoList()
}


extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 72, height: 72)
    }
    
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contentView.collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        let lastItemIndex = contentView.collectionView.numberOfItems(inSection: indexPath.section) - 1
        
        if indexPath.item == lastItemIndex {
            cell.setDayLabel(text: "Другое")
        } else {
            let date = dateParser(dates[indexPath.row])
            cell.setDayLabel(text: date.day)
            cell.setMonthLabel(text: date.month)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dict.keys.count
    }
    
    func dateParser(_ dateString: String) -> (day: String, month: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)!
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        let day = dayFormatter.string(from: date)
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let month = monthFormatter.string(from: date)
        
        return (day: day, month: month)
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let targetIndexPath = IndexPath(row: 0, section: indexPath.row)
        contentView.tableView.scrollToRow(at: targetIndexPath, at: .top, animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let firstVisibleSection = contentView.tableView.indexPathsForVisibleRows?.first?.section {
            let indexPath = IndexPath(item: firstVisibleSection, section: 0)
            contentView.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
    
}

extension CalendarViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].todos.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections[section].date == "Другое" {
            return sections[section].date
        } else {
            let date = dateParser(sections[section].date)
            return "\(date.day) \(date.month)"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ItemCell",
                for: indexPath
            ) as? UITableViewCell & CellConfigurable
        else {
            return UITableViewCell()
        }
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            cell.layer.cornerRadius = 10
        } else {
            let isFirstCell = indexPath.row == 0
                   let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
                   if isFirstCell || isLastCell {
                       cell.layer.cornerRadius = 10
                       cell.clipsToBounds = true
                       cell.layer.maskedCorners = isFirstCell ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                   }
        }
        
        
        let task = sections[indexPath.section].todos[indexPath.item]
        cell.configure(with: task)
        return cell
    }
}


extension CalendarViewController: UITableViewDelegate {
    func scrollToTableCell(at indexPath: IndexPath, animated: Bool = true) {
        contentView.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
}

extension CalendarViewController {
    @objc func openTodoItemView() {
        let newItem = todoListViewModel.openedItem
        todoListViewModel.addItem(newItem)
        let viewModel = TodoItemViewModel(todoItem: newItem)
        let swiftUIHostingController = UIHostingController(rootView: TodoItemView(viewModel: viewModel))
        present(swiftUIHostingController, animated: true)
    }
}

extension CalendarViewController: TodoListViewControllerDelegate {
    func didUpdateTodoList() {
        contentView.tableView.reloadData()
        contentView.collectionView.reloadData()
    }
}
