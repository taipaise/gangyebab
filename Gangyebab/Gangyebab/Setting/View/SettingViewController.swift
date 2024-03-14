//
//  SettingViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/7/24.
//

import UIKit
import Combine
import MessageUI

final class SettingViewController: UIViewController {

    @IBOutlet private weak var notificatinSettingButton: UIButton!
    @IBOutlet private weak var contactButton: UIButton!
    @IBOutlet private weak var reviewButton: UIButton!
    @IBOutlet private weak var licenseButton: UIButton!
    @IBOutlet private weak var donateButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    
    private var viewModel = SettingViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
        bindViewModel()
    }
}

// MARK: - Binding
extension SettingViewController {
    private func bindView() {
        contactButton.safeTap
            .sink { [weak self] _ in
                self?.sendMail()
            }
            .store(in: &cancellables)
    }
    
    private func bindViewModel() {
        viewModel.$currentAppVersion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] version in
                self?.versionLabel.text = version
            }
            .store(in: &cancellables)
    }
}

// MARK: - handle mail
extension SettingViewController {
    private func sendMail() {
        guard MFMailComposeViewController.canSendMail() else {
            // TODO: - 커스텀 alert 등록
            print("메일 전송 불가")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        let bodyString = """
                         아래에 문의 내용을 작성해 주세요.
                         
                         
                         
                         ================================
                         Device Model : \(UIDevice.current.modelName)
                         Device OS : \(UIDevice.current.systemVersion)
                         App Version : \(viewModel.currentAppVersion)
                         ================================
                         """
        composeVC.setToRecipients(["taipaise@gmail.com"])
        composeVC.setSubject("간계밥 문의 사항")
        composeVC.setMessageBody(bodyString, isHTML: false)
        present(composeVC, animated: true)
    }
}

// MARK: - mail delegate
extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        // TODO: - custom alert 등록하기
        switch result {
        case .cancelled:
            print("메일 보내기 취소")
        case .saved:
            print("임시 저장")
        case .sent:
            print("메일 보내기 성공")
        case .failed:
            print("메일 보내기 실패")
        @unknown default:
            break
        }
        
        dismiss(animated: true)
    }
}
