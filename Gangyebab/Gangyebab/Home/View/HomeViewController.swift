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
    @IBOutlet private weak var addImage: UIImageView!
    @IBOutlet private weak var addButton1: UIButton!
    @IBOutlet private weak var addButton2: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    
    private var doubleTapGestureRecognizer: UITapGestureRecognizer?
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
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapTodo(_:)))
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delaysTouchesBegan = true
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
        
        viewModel.cellModels
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(_) = completion else { return }
            } receiveValue: { [weak self] cellModels in
                if
                    cellModels.inProgress.isEmpty,
                    cellModels.completed.isEmpty
                {
                    self?.editButton.isHidden = true
                    self?.todoCollectionView.isHidden = true
                } else {
                    self?.editButton.isHidden = false
                    self?.todoCollectionView.isHidden = false
                    
                    if self?.viewModel.isEditing ?? true {
                        self?.applyItems(cellModels: cellModels, animating: false)
                    } else {
                        self?.applyItems(cellModels: cellModels, animating: true)
                    }
                    
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isEditing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing in
                self?.setDoubleTapGestureRecognizer(isEditing)
                self?.addImage.isHidden = isEditing
                self?.addButton1.isHidden = isEditing
                self?.addButton2.isHidden = isEditing
                self?.deleteButton.isHidden = !isEditing
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
        
        editButton.safeTap
            .sink { [weak self] _ in
                self?.viewModel.action(.editTapped)
            }
            .store(in: &cancellables)
        
        deleteButton.safeTap
            .sink { [weak self] _ in
                self?.viewModel.action(.deleteTodo)
            }
            .store(in: &cancellables)
    }
}

// MARK: - CollectionView 설정
extension HomeViewController {
    
    private func configureCollectionView()  {
        todoCollectionView.delegate = self
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
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func applyItems(cellModels: TodoCellModels, animating: Bool) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.inProgress, .completed])
        snapshot.appendItems(cellModels.inProgress, toSection: .inProgress)
        snapshot.appendItems(cellModels.completed, toSection: .completed)
        
        dataSource?.apply(snapshot, animatingDifferences: animating)
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
    
    private func setDoubleTapGestureRecognizer(_ isEditing: Bool) {
        guard let doubleTapGestureRecognizer = doubleTapGestureRecognizer else { return }
     
        if isEditing {
            editButton.setTitle("완료", for: .normal)
            editButton.titleLabel?.font = .omyu(size: 18)
            todoCollectionView.removeGestureRecognizer(doubleTapGestureRecognizer)
        } else {
            editButton.setTitle("편집", for: .normal)
            editButton.titleLabel?.font = .omyu(size: 18)
            todoCollectionView.addGestureRecognizer(doubleTapGestureRecognizer)
        }
    }
}

// MARK: - CollectionView delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if viewModel.isEditing {
            viewModel.action(.checkTodo(indexPath))
        } else {
            guard section == TodoSection.inProgress.rawValue else { return }
            
            let cellModels = viewModel.inprogressCellModels
            let cellModel = cellModels[row]

            let nextVC = AddTodoViewController()
            nextVC.delegate = self
            nextVC.configure(cellModel)
            nextVC.modalPresentationStyle = .overFullScreen
            present(nextVC, animated: false)
        }
    }
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
