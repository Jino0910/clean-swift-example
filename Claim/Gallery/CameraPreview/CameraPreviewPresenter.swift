//
//  CameraPreviewPresenter.swift
//  Bomapp
//
//  Created by rowkaxl on 26/02/2019.
//  Copyright (c) 2019 Redvelvet Ventures Inc. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CameraPreviewPresentationLogic {
    func presentSomething(response: CameraPreview.Something.Response)
}

class CameraPreviewPresenter: CameraPreviewPresentationLogic {
    weak var viewController: CameraPreviewDisplayLogic?

    // MARK: Do something

    func presentSomething(response: CameraPreview.Something.Response) {
        let viewModel = CameraPreview.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
}
