//
//  ClaimConfirmInteractor.swift
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

protocol ClaimConfirmBusinessLogic {
    func getSectionModel()
}

protocol ClaimConfirmDataStore {
    //var name: String { get set }
}

class ClaimConfirmInteractor: ClaimConfirmBusinessLogic, ClaimConfirmDataStore {
    var presenter: ClaimConfirmPresentationLogic?
    var worker = ClaimConfirmWorker()
    //var name: String = ""

    // MARK: Do something

    func getSectionModel() {

        let sectionModel = self.worker.getClaimSectionModel()
        let response = ClaimConfirm.SectionItem.Response(claimSectionModel: sectionModel)
        self.presenter?.presentSectionModel(response: response)
    }
}
