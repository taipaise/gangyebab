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
    typealias DataSource = UICollectionViewDiffableDataSource<TodoSection, TodoModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TodoSection, TodoModel>
    
    @IBOutlet private weak var homeSegmentedControl: HomeSegmentedControl!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var todoCollectionView: UICollectionView!
    @IBOutlet private weak var addImage: UIImageView!
    @IBOutlet private weak var addButton1: UIButton!
    @IBOutlet private weak var addButton2: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var monthLabel: UILabel!
    @IBOutlet private weak var todayButton: UIButton!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.action(.viewWillAppear)
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
        calendar.delegate = self
        calendar.select(Date())
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapTodo(_:)))
        doubleTapGestureRecognizer?.numberOfTapsRequired = 2
        doubleTapGestureRecognizer?.delaysTouchesBegan = true
        if let gesture = doubleTapGestureRecognizer { todoCollectionView.addGestureRecognizer(gesture) }
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
                    self?.monthLabel.isHidden = true
                    self?.dateLabel.isHidden = false
                    self?.nextButton.isHidden = false
                    self?.previousButton.isHidden = false
                case .month:
                    self?.calendar.isHidden = false
                    self?.calendar.select(self?.viewModel.date.value)
                    self?.dateLabel.isHidden = true
                    self?.monthLabel.isHidden = false
                    self?.nextButton.isHidden = true
                    self?.previousButton.isHidden = true
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
                    self?.todoCollectionView.isHidden = true
                } else {
                    self?.todoCollectionView.isHidden = false
                    self?.applyItems(cellModels: cellModels)
                }
            }
            .store(in: &cancellables)
        
        viewModel.dateString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dateString in
                self?.dateLabel.text = dateString
            }
            .store(in: &cancellables)
        
        viewModel.monthString
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dateString in
                self?.monthLabel.text = dateString
            }
            .store(in: &cancellables)
        
        viewModel.$isToday
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isToday in
                self?.todayButton.isHidden = isToday
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
                    guard let date = self?.viewModel.date.value else { return }
                    let nextVC = AddTodoViewController()
                    nextVC.configure(date: date, todo: nil)
                    nextVC.delegate = self
                    nextVC.modalPresentationStyle = .overFullScreen
                    nextVC.modalTransitionStyle = .crossDissolve
                    self?.present(nextVC, animated: true)
                })
                .store(in: &cancellables)
        }
        
        todayButton.safeTap
            .sink { [weak self] _ in
                self?.viewModel.action(.todayButtonTapped)
                self?.calendar.select(Date())
            }
            .store(in: &cancellables)
    }
}

// MARK: - CollectionView 설정
extension HomeViewController {
    
    private func configureCollectionView()  {
        todoCollectionView.delegate = self
        todoCollectionView.collectionViewLayout = createLayout()
        todoCollectionView.backgroundColor = .background1
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
            
            if let cell = cell as? TodoCell { cell.configure(cellModel) }
            
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
    
    private func applyItems(cellModels: TodoCellModels) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.inProgress, .completed])
        snapshot.appendItems(cellModels.inProgress, toSection: .inProgress)
        snapshot.appendItems(cellModels.completed, toSection: .completed)
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return .init(actions: []) }
            
            let todo: TodoModel
            
            if indexPath.section == 0 {
                todo = self.viewModel.inprogressCellModels[indexPath.row]
            } else {
                todo = self.viewModel.completedCellModels[indexPath.row]
            }
            
            let delete = UIContextualAction(style: .normal, title: nil) { action, view, actionPerformed in
                AlertBuilder(
                    message: "정말 삭제하시겠습니까?",
                    pointAction: CustomAlertAction(
                        text: "확인",
                        action: {
                            if todo.repeatType == .none {
                                self.viewModel.action(.deleteTodo(indexPath, deleteAll: false))
                            } else {
                                AlertBuilder(
                                    message: "반복 이벤트입니다.\n모든 이벤트를 모두 삭제할까요?",
                                    pointAction: CustomAlertAction(
                                        text: "모두 삭제",
                                        action: {
                                            self.viewModel.action(.deleteTodo(indexPath, deleteAll: true))
                                        }),
                                    generalAction: CustomAlertAction(
                                        text: "이 날만 삭제",
                                        action: {
                                            self.viewModel.action(.deleteTodo(indexPath, deleteAll: false))
                                        }
                                    )
                                )
                                .show(self)
                            }
                        }
                    )
                )
                .show(self)
                
                actionPerformed(true)
            }
            delete.image = UIImage(systemName: "trash.fill")
            delete.backgroundColor = .red
            return .init(actions: [delete])
        }
        
        configuration.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration.separatorConfiguration.color = .stringColor1
        configuration.backgroundColor = .background1
        
        return configuration
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let section: NSCollectionLayoutSection
            let configuration = self?.createListConfiguration()
            
            section = NSCollectionLayoutSection.list(
                using: configuration ?? UICollectionLayoutListConfiguration(appearance: .plain),
                layoutEnvironment: layoutEnvironment
            )
            section.contentInsets = NSDirectionalEdgeInsets(
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
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    @objc private func doubleTapTodo(_ gestureRecognizer: UIGestureRecognizer) {
        
        let location = gestureRecognizer.location(in: todoCollectionView)
        
        guard let indexPath = todoCollectionView.indexPathForItem(at: location) else { return }
        viewModel.action(.toggleComplete(indexPath))
    }
}

// MARK: - CollectionView delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        guard section == TodoSection.inProgress.rawValue else { return }
        
        let cellModels = viewModel.inprogressCellModels
        let cellModel = cellModels[row]
        print(cellModel)
        let date = viewModel.date.value
        let nextVC = AddTodoViewController()
        nextVC.configure(date: date, todo: cellModel)
        nextVC.delegate = self
        nextVC.modalPresentationStyle = .overFullScreen
        nextVC.modalTransitionStyle = .crossDissolve
        present(nextVC, animated: true)
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
    func transferTodo(todo: TodoModel, isEditing: Bool) {
        if isEditing {
            viewModel.action(.updateTodo(todo))
        } else {
            viewModel.action(.addTodo(todo))
        }
    }
}

// MARK: - FS calendar delegate
extension HomeViewController: FSCalendarDelegate {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        viewModel.action(.calendarSwipe(calendar.currentPage))
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.action(.dateSelected(date))
    }
}
