//
//  SelectTodoViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/23/24.
//

import UIKit
import Combine

final class SelectTodoViewController: UIViewController {
    typealias TodoCell = TodoCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource<Int, TodoModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, TodoModel>
    
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var todoCollectionView: UICollectionView!
    @IBOutlet private weak var addButton: UIButton!
    private var dataSource: DataSource?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
    }
}

// MARK: - Binding
extension SelectTodoViewController {
    private func bindView() {
        dismissButton.safeTap
            .sink { [weak self] _ in
                guard let self = self else { return }
                AlertBuilder(
                    message: "아무 일정도 추가하지 않으시겠습니까?",
                    pointAction: CustomAlertAction(
                        text: "확인",
                        action: {
                            self.dismiss(animated: true)
                        }
                    ),
                    generalAction: CustomAlertAction(
                        text: "취소",
                        action: {}
                    )
                )
                .show(self)
            }
            .store(in: &cancellables)
        
        addButton.safeTap
            .sink { _ in
                
            }
            .store(in: &cancellables)
    }
    
}

// MARK: - collectionView configuration
extension SelectTodoViewController {
    private func configureCollectionView()  {
        todoCollectionView.delegate = self
        todoCollectionView.collectionViewLayout = createLayout()
        todoCollectionView.backgroundColor = .background1
        todoCollectionView.register(cells: [TodoCell.self])
        
        dataSource = .init(collectionView: todoCollectionView) {
            collectionView, indexPath, cellModel in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TodoCell.className,
                for: indexPath
            )
            
            if let cell = cell as? TodoCell { cell.configure(cellModel) }
            
            return cell
        }
    }
    
    private func applyItems(cellModels: [TodoModel]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([0])
        snapshot.appendItems(cellModels)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func createListConfiguration() -> UICollectionLayoutListConfiguration {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
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
                using: UICollectionLayoutListConfiguration(appearance: .plain),
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
                heightDimension: .estimated(52)
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
}

// MARK: - CollectionView delegate
extension SelectTodoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row

        guard let cell = collectionView.cellForItem(at: indexPath) as? TodoCell else { return }
        cell.toggleCheck()
    }
}
