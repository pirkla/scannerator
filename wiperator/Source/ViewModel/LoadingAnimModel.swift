//
//  EnvironmentViewModel.swift
//  Scannerator
//
//  Created by Andrew Pirkl on 6/17/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

class LoadingAnimModel: ObservableObject {
    @Published var isLoading: Bool = true
    
    var loadingCount: Int = 0
//    {
//        willset(newValue) {
//            isLoading = (newValue > 0)
//        }
//    }
}
