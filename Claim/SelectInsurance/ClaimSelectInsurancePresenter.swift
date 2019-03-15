//
//  ClaimSelectInsurancePresenter.swift
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
import BomappDM
import SwiftyJSON

protocol ClaimSelectInsurancePresentationLogic {
    func presentInsuranceList(response: ClaimSelectInsurance.CompList.Response)
    func presentPDFData(response: ClaimSelectInsurance.PDFData.Response)
    func presentSaveClaimSingleton()
}

class ClaimSelectInsurancePresenter: ClaimSelectInsurancePresentationLogic {
    weak var viewController: ClaimSelectInsuranceDisplayLogic?

    // MARK: Do something

    func presentInsuranceList(response: ClaimSelectInsurance.CompList.Response) {

        let compList = getInsuranceCompModel(response: response)
        let sectionModel = getClaimSectionModel(compList: compList)
        let viewModel = ClaimSelectInsurance.CompList.ViewModel(compList: compList, claimSectionModel: sectionModel)
        viewController?.displayInsuranceList(viewModel: viewModel)
    }

    func presentPDFData(response: ClaimSelectInsurance.PDFData.Response) {

//        guard let pdfURL = response.json["data", "formUrl"].string else { return }
//        let viewModel = ClaimSelectInsurance.PDFData.ViewModel(pdfURL: pdfURL)

        let viewModel = ClaimSelectInsurance.PDFData.ViewModel()
        viewController?.displayPDFView(viewModel: viewModel)
    }

    func presentSaveClaimSingleton() {
        viewController?.displaySaveClaimSingleton()
    }
}

extension ClaimSelectInsurancePresenter {

    func getInsuranceCompModel(response: ClaimSelectInsurance.CompList.Response) -> [InsuranceCompModel] {

        guard let data = response.json["data"].array else { return [] }

        var list: [InsuranceCompModel] = []
        for item in data {
            list.append(InsuranceCompModel(item))
        }

        if ClaimSingleton.instance.claimState == .successFAX {
            if let insCode = ClaimSingleton.instance.insuranceList.value.first?.code {
                list = list.filter({ (model) -> Bool in
                    guard let modelCode = model.code else { return false }
                    return modelCode != insCode
                })
            }
        }
        return list
    }

    public func getClaimSectionModel(compList: [InsuranceCompModel]) -> [ClaimSectionModel] {

        var model: [ClaimSectionModel] =
            [
                ClaimSectionModel(model: ClaimSectionID.section1,
                                  items: [
                                    ClaimModelItem(claimType: .headerDefault(title: "청구 보험사 선택",
                                        description: "보험금 청구를 위해 보험사를 선택해주세요.\n복수 선택이 가능합니다.")),
                                    ClaimModelItem(claimType: .empty(height: 56)),
                                    ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0x4d4d4d), leading: 20))
                    ])
        ]

        if compList.count > 0 {

            for comp in compList {

                let logoImage = UIImage(named: "logo\(comp.code ?? "000")Re", in: BDMBundle, compatibleWith: nil) ?? UIImage()
                let insName = comp.name ?? ""
                let insCnt = (comp.insCnt == "0") ? "" : "가입 보험 상품 : \(comp.insCnt ?? "")건"
                let availableFaxType: Bool =  (comp.availableFaxType == "1") ? true : false

                model.append(ClaimSectionModel(model: ClaimSectionID.section2,
                                                      items: [
                                                        ClaimModelItem(claimType: .empty(height: 20)),
                                                        ClaimModelItem(claimType: .compListView(logoImage: logoImage, insName: insName, insCnt: insCnt, term: "약관보기", availableFaxType: availableFaxType),
                                                                       value: JSON(["code": comp.code])),
                                                        ClaimModelItem(claimType: .empty(height: 20)),
                                                        ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0xefefef), leading: 20))
                    ]))
            }
        }

        model.append(ClaimSectionModel(model: ClaimSectionID.section3, items: [
            ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0xd8d8d8), leading: 0)),
            ClaimModelItem(claimType: .medicalNoticeView(description: "선택된 보험사의 약관에 동의됩니다.".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))))
            ]))

        return model
    }
}
