//
//  ClaimGuidePresenter.swift
//  Bomapp
//
//  Created by rowkaxl on 25/02/2019.
//  Copyright (c) 2019 Redvelvet Ventures Inc. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ClaimGuidePresentationLogic {
    func presentSectionModel(response: ClaimGuide.SectionItem.Response)
}

class ClaimGuidePresenter: ClaimGuidePresentationLogic {
    weak var viewController: ClaimGuideDisplayLogic?

    // MARK: Do something

    func presentSectionModel(response: ClaimGuide.SectionItem.Response) {
        let viewModel = ClaimGuide.SectionItem.ViewModel(claimSectionModel: response.claimSectionModel)
        viewController?.displaySectionModel(viewModel: viewModel)
    }
}