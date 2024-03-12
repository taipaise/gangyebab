//
//  HomeViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/7/24.
//

import UIKit
import FSCalendar

final class HomeViewController: UIViewController {

    @IBOutlet private weak var homeSegmentedControl: HomeSegmentedControl!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var todoCollectionView: UICollectionView!
    
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

extension HomeViewController: UICollectionViewDelegate {
    
}

// MARK: - segemted control delegate
extension HomeViewController: HomeSegmentedControlDelegate {
    func segmentChanged() {
        // TODO: - 달력 처리 로직
    }
}
