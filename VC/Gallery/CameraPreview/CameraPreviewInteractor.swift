//
//  CameraPreviewInteractor.swift
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

protocol CameraPreviewBusinessLogic {
    func doSomething(request: CameraPreview.Something.Request)
}

protocol CameraPreviewDataStore {
    //var name: String { get set }
}

class CameraPreviewInteractor: CameraPreviewBusinessLogic, CameraPreviewDataStore {
    var presenter: CameraPreviewPresentationLogic?
    var worker: CameraPreviewWorker?
    //var name: String = ""

    // MARK: Do something

    func doSomething(request: CameraPreview.Something.Request) {
        worker = CameraPreviewWorker()
        worker?.doSomeWork()

        let response = CameraPreview.Something.Response()
        presenter?.presentSomething(response: response)
    }
}