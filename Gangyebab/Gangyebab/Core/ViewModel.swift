//
//  ViewModel.swift
//  Gangyebab
//
//  Created by 이동현 on 3/12/24.
//

import Combine

@MainActor protocol ViewModel: ObservableObject where ObjectWillChangePublisher.Output == Void {
    associatedtype Input
    
    func action(_ input: Input)
}
