//
//  ClaimInputClaimWorker.swift
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

class ClaimInputClaimWorker {

    public func getClaimSectionModel() -> [ClaimSectionModel] {

        var model: [ClaimSectionModel] =
            [
                ClaimSectionModel(model: ClaimSectionID.section1,
                                  items: [
                                    ClaimModelItem(claimType: .headerDefault(title: "청구 내용 입력",
                                        description: "여러 번 치료받으신 경우, 최초 사고 일을 입력하시고\n치료기간 동안의 서류를 한번에 등록하시면 편합니다.")),
                                    ClaimModelItem(claimType: .empty(height: 56))
                    ])
        ]

        model.append(ClaimSectionModel(model: ClaimSectionID.section2,
                                       items: [
                                        ClaimModelItem(claimType: .infoCategoryType1(title: "사고 정보 입력", subTitle: NSAttributedString(), buttonTitle: "", isHiddenButton: true)),
                                        ClaimModelItem(claimType: .empty(height: 20)),
                                        ClaimModelItem(claimType: .inputRadio(title: "사고유형", btnTitles: ["질병", "상해/재해"])),
                                        ClaimModelItem(claimType: .empty(height: 20)),
                                        ClaimModelItem(claimType: .inputDefault(title: "사고(발병)일시", placeholder: "날짜를 선택해주세요.", lineColor: UIColor(rgb: 0xefefef))),
                                        ClaimModelItem(claimType: .empty(height: 20)),
                                        ClaimModelItem(claimType: .inputDefault(title: "진단명 또는 병명", placeholder: "예) 감기, 골절", lineColor: UIColor(rgb: 0xefefef))),
                                        ClaimModelItem(claimType: .empty(height: 50))
            ]))

        return model
    }
}
