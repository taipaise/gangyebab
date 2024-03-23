//
//  LicenseDetailViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/23/24.
//

import Foundation
import Combine

final class LicenseDetailViewModel {
    @Published private(set) var title = ""
    @Published private(set) var detail = ""
    
    func configure(_ license: License) {
        title = license.name
        detail = license.detail
    }
}
