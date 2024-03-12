//
//  HomeViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/7/24.
//

import UIKit
import FSCalendar

final class HomeViewController: UIViewController {
    typealias TodoCell = TodoCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource<TodoSection, TodoCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TodoSection, TodoCellModel>
    
    @IBOutlet private weak var homeSegmentedControl: HomeSegmentedControl!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var todoCollectionView: UICollectionView!
    private var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
}

// MARK: - UISetting
extension HomeViewController {
    private func setUI() {
        homeSegmentedControl.delegate = self
        todoCollectionView.delegate = self
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 10
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.weekdayFont = .omyu(size: 18)
    }
}

// MARK: - CollectionView 설정
extension HomeViewController {
    
    private func configureCollectionView()  {
        todoCollectionView.collectionViewLayout = createCollectionViewLayout()
        todoCollectionView.register(cells: [TodoCell.self])
        dataSource = .init(collectionView: todoCollectionView) {
            collectionView, indexPath, cellModel in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TodoCell.className,
                for: indexPath
            )
            
            if let cell = cell as? TodoCell {
                cell.configure(cellModel)
            }
            
            return cell
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1.0)
            )

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
            
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
                leading: .fixed(0),
                top: .fixed(30),
                trailing: .fixed(0),
                bottom: .fixed(0)
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets =
            NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
            return section
        }
        return layout
    }

}

extension HomeViewController: UICollectionViewDelegate {
    
}

// MARK: - segemted control delegate
extension HomeViewController: HomeSegmentedControlDelegate {
    func segmentChanged() {
        // TODO: - 달력 처리 로직
    }
}
