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

    
    @IBOutlet private weak var yesterdaySwitch: UISwitch!
    @IBOutlet private weak var contactButton: UIButton!
    @IBOutlet private weak var reviewButton: UIButton!
    @IBOutlet private weak var licenseButton: UIButton!
    @IBOutlet private weak var donateButton: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    
    private var viewModel = SettingViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindView()
        bindViewModel()
    }
    
    private func setUI() {
        yesterdaySwitch.setOn(viewModel.switchState, animated: false)
    }
    
    @IBAction private func switchToggle(_ sender: UISwitch) {
        viewModel.action(.toggle(sender.isOn))
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
        
        donateButton.safeTap
            .sink { [weak self] _ in
                let nextVC = DonateViewController()
                self?.navigationController?.pushViewController(nextVC, animated: true)
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
        
        viewModel.$switchState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.yesterdaySwitch.setOn(state, animated: true)
            }
            .store(in: &cancellables)
    }
}

// MARK: - handle mail
extension SettingViewController {
    private func sendMail() {
        guard MFMailComposeViewController.canSendMail() else {
            AlertBuilder(
                message: "이메일을 사용할 수 없습니다.\n이메일 설정을 확인해주세요.",
                pointAction: CustomAlertAction(
                    text: "확인",
                    action: {}
                )
            )
            .show(self)
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
        dismiss(animated: true)
        switch result {
        case .cancelled:
            break
        case .saved:
            print("임시저장")
            AlertBuilder(
                message: "이메일이 임시 저장되었습니다.",
                pointAction: CustomAlertAction(
                    text: "확인",
                    action: {}
                )
            )
            .show(self)
            print(self)
        case .sent:
            AlertBuilder(
                message: "문의를 성공적으로 보냈습니다.",
                pointAction: CustomAlertAction(
                    text: "확인",
                    action: {}
                )
            )
            .show(self)
        case .failed:
            AlertBuilder(
                message: "이메일 전송이 실패하였습니다.",
                pointAction: CustomAlertAction(
                    text: "확인",
                    action: {}
                )
            )
            .show(self)
        @unknown default:
            break
        }
    }
}
