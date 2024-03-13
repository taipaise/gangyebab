//
//  HomeViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/7/24.
//

import UIKit
import FSCalendar
import Combine

final class HomeViewController: UIViewController {
    typealias TodoHeaderView = TodoHeaderSupplementaryView
    typealias TodoCell = TodoCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource<TodoSection, TodoCellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TodoSection, TodoCellModel>
    
    @IBOutlet private weak var homeSegmentedControl: HomeSegmentedControl!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var todoCollectionView: UICollectionView!
    @IBOutlet private weak var addButton1: UIButton!
    @IBOutlet private weak var addButton2: UIButton!
    
    private var dataSource: DataSource?
    private var viewModel = HomeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        configureCollectionView()
        bindViewModel()
        bindView()
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

// MARK: - biding
extension HomeViewController {
    func bindViewModel() {
        viewModel.homeType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                self?.homeSegmentedControl.configure(type)
                switch type {
                case .day:
                    self?.calendar.isHidden = true
                case .month:
                    self?.calendar.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        viewModel.inprogressCellModels
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(_) = completion else { return }
            } receiveValue: { [weak self] inProgress in
                self?.updateItems(section: .inProgress, items: inProgress)
            }
            .store(in: &cancellables)
        
        viewModel.completedCellModels
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(_) = completion else { return }
            } receiveValue: { [weak self] completed in
                self?.updateItems(section: .completed, items: completed)
            }
            .store(in: &cancellables)
    }
    
    private func bindView() {
        previousButton.safeTap
            .sink { [weak self] _ in
                self?.viewModel.action(.previousButton)
            }
            .store(in: &cancellables)
        
        nextButton.safeTap
            .sink { [weak self] _ in
                self?.viewModel.action(.nextButton)
            }
            .store(in: &cancellables)
        
        [addButton1, addButton2].forEach { button in
            button?.safeTap
                .sink(receiveValue: { [weak self] in
                    let nextVC = AddTodoViewController()
                    nextVC.delegate = self
                    nextVC.modalPresentationStyle = .overFullScreen
                    self?.present(nextVC, animated: false)
                })
                .store(in: &cancellables)
        }
    }
}

// MARK: - CollectionView 설정
extension HomeViewController {
    
    private func configureCollectionView()  {
        todoCollectionView.collectionViewLayout = createCollectionViewLayout()
        todoCollectionView.register(cells: [TodoCell.self])
        todoCollectionView.register(
            UINib.init(nibName: TodoHeaderView.className, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TodoHeaderView.className
        )
        
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
        
        var snapshot = Snapshot()
        snapshot.appendSections([.inProgress, .completed])
        snapshot.appendItems([])
        
        dataSource?.supplementaryViewProvider = { [weak self] view, kind, indexPath in
            let header = self?.todoCollectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: TodoHeaderView.className,
                for: indexPath
            ) as? TodoHeaderView
            
            if indexPath.section == TodoSection.inProgress.rawValue {
                header?.configure(.inProgress)
            } else {
                header?.configure(.completed)
            }
        
            return header
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapTodo))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.delaysTouchesBegan = true
        todoCollectionView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func updateItems(section: TodoSection, items: [TodoCellModel]) {
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: section))
        snapshot.appendItems(items, toSection: section)
        dataSource?.apply(snapshot)
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
                heightDimension: .absolute(30)
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
                top: .fixed(7),
                trailing: .fixed(0),
                bottom: .fixed(0)
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets =
            NSDirectionalEdgeInsets(
                top: 5,
                leading: 0,
                bottom: 30,
                trailing: 0
            )
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(30)
            )
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        return layout
    }
    
    @objc private func doubleTapTodo(_ gestureRecognizer: UIGestureRecognizer) {

        let location = gestureRecognizer.location(in: todoCollectionView)
        
        guard let indexPath = todoCollectionView.indexPathForItem(at: location) else { return }
        viewModel.action(.toggleComplete(indexPath))
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}

// MARK: - segemted control delegate
extension HomeViewController: HomeSegmentedControlDelegate {
    func segmentChanged() {
        viewModel.action(.toggleHomeType)
    }
}


// MARK: - add todo delegate
extension HomeViewController: AddTodoDelegate {
    func transferTodo(_ todo: TodoCellModel) {
        viewModel.action(.updateTodo(todo))
    }
}
