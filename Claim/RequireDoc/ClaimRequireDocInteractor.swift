//
//  ClaimRequireDocInteractor.swift
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

protocol ClaimRequireDocBusinessLogic {
    func getSectionModel()
}

protocol ClaimRequireDocDataStore {

}

class ClaimRequireDocInteractor: ClaimRequireDocBusinessLogic, ClaimRequireDocDataStore {
    var presenter: ClaimRequireDocPresentationLogic?
    var worker = ClaimRequireDocWorker()

    // MARK: Do something

    func getSectionModel() {

        let sectionModel = self.worker.getClaimSectionModel()
        let response = ClaimRequireDoc.SectionItem.Response(claimSectionModel: sectionModel)
        self.presenter?.presentSectionModel(response: response)
    }
}