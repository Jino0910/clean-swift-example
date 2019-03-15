//
//  CameraPreviewListInteractor.swift
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

protocol CameraPreviewListBusinessLogic {
    func doSomething(request: CameraPreviewList.Something.Request)
}

protocol CameraPreviewListDataStore {
    //var name: String { get set }
}

class CameraPreviewListInteractor: CameraPreviewListBusinessLogic, CameraPreviewListDataStore {
    var presenter: CameraPreviewListPresentationLogic?
    var worker: CameraPreviewListWorker?
    //var name: String = ""

    // MARK: Do something

    func doSomething(request: CameraPreviewList.Something.Request) {
        worker = CameraPreviewListWorker()
        worker?.doSomeWork()

        let response = CameraPreviewList.Something.Response()
        presenter?.presentSomething(response: response)
    }
}