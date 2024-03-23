//
//  LicenseViewController.swift
//  Gangyebab
//
//  Created by 이동현 on 3/23/24.
//

import UIKit
import Combine

final class LicenseViewController: UIViewController {

    @IBOutlet private var buttons: [UIButton]!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
    }
}

extension LicenseViewController {
    private func bindView() {
        buttons.forEach { button in
            button.safeTap
                .sink { [weak self] in
                    guard 
                        let self = self,
                        let license = License.init(rawValue: button.tag)
                    else { return }
                    let nextVC = LicenseDetailViewController()
                    nextVC.configure(license)
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                .store(in: &cancellables)
        }
    }
}


enum License: Int {
    case combineCocoa
    case canlendar
    case rater
    
    var name: String {
        switch self {
        case .combineCocoa:
            return "CombineCocoa"
        case .canlendar:
            return "FSCalendar"
        case .rater:
            return "SwiftRater"
        }
    }
    
    var detail: String {
        switch self {
        case .combineCocoa:
            return """
                   MIT License

                   Copyright (c) 2019 Shai Mishali

                   Permission is hereby granted, free of charge, to any person obtaining a copy
                   of this software and associated documentation files (the "Software"), to deal
                   in the Software without restriction, including without limitation the rights
                   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                   copies of the Software, and to permit persons to whom the Software is
                   furnished to do so, subject to the following conditions:

                   The above copyright notice and this permission notice shall be included in all
                   copies or substantial portions of the Software.

                   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                   SOFTWARE.
                   """
        case .canlendar:
            return """
                   Copyright (c) 2013-2016 FSCalendar (https://github.com/WenchaoD/FSCalendar)

                   Permission is hereby granted, free of charge, to any person obtaining a copy
                   of this software and associated documentation files (the "Software"), to deal
                   in the Software without restriction, including without limitation the rights
                   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                   copies of the Software, and to permit persons to whom the Software is
                   furnished to do so, subject to the following conditions:

                   The above copyright notice and this permission notice shall be included in
                   all copies or substantial portions of the Software.

                   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                   THE SOFTWARE.
                   """
        case .rater:
            return """
                   Copyright (c) 2017 takecian <takecian@gmail.com>

                   Permission is hereby granted, free of charge, to any person obtaining a copy
                   of this software and associated documentation files (the "Software"), to deal
                   in the Software without restriction, including without limitation the rights
                   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                   copies of the Software, and to permit persons to whom the Software is
                   furnished to do so, subject to the following conditions:

                   The above copyright notice and this permission notice shall be included in
                   all copies or substantial portions of the Software.

                   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
                   THE SOFTWARE.
                   """
        }
    }
}
