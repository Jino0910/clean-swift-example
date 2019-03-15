//
//  ClaimRequireDocInfoInteractor.swift
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

protocol ClaimRequireDocInfoBusinessLogic {
    func doSomething(request: ClaimRequireDocInfo.Something.Request)
}

protocol ClaimRequireDocInfoDataStore {
    //var name: String { get set }
}

class ClaimRequireDocInfoInteractor: ClaimRequireDocInfoBusinessLogic, ClaimRequireDocInfoDataStore {
    var presenter: ClaimRequireDocInfoPresentationLogic?
    var worker: ClaimRequireDocInfoWorker?
    //var name: String = ""

    // MARK: Do something

    func doSomething(request: ClaimRequireDocInfo.Something.Request) {
        worker = ClaimRequireDocInfoWorker()
        worker?.doSomeWork()

        let response = ClaimRequireDocInfo.Something.Response()
        presenter?.presentSomething(response: response)
    }
}