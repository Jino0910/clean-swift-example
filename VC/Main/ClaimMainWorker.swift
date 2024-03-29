//
//  ClaimMainWorker.swift
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
import RxCocoa
import RxSwift
import RealmSwift
import SwiftyJSON
import Async
import BomappDM
import AFDateHelper

class ClaimMainWorker {

    let disposeBag = DisposeBag()

    let realm = try! Realm()

    // 팩스 상태 조회
    public func requestFaxState(claimList: Results<ClaimItem>) {

        var faxUuids: [String] = []

        for claim in claimList {
            if !claim.faxUUID.isEmpty && claim.stateEnum != .checkPayout
                && claim.stateEnum != .payout
                && claim.stateEnum != .noPayout {
                faxUuids.append(claim.faxUUID)
            }
        }

        guard faxUuids.count > 0 else { return }

        APIManager.request(target: Bomapp.claimStateSendFAX(faxUuid: faxUuids.joined(separator: ",")))
            .subscribe(onSuccess: responseFaxState)
            .disposed(by: disposeBag)
    }

    // 삭제하기
    public func deleteClaim(claimItem: ClaimItem) {

        PopupManager.selectPopup(title: BomappString.Claim.claimListDeleteAlertTitle, content: "")
            .subscribe(onSuccess: { (value) in
                if value {
                    let item = claimItem
                    try! self.realm.write {
                        self.realm.delete(item)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    // PDF 파일
//    public func getClaimPDF(claimItem: ClaimItem) -> (Bool, Data) {

//        if let pdf = claimItem.pdfData {
//            return (true, pdf)
//        } else {
//
//            API.rx.request(Bomapp.claimDownloadFile(faxUuid: claimItem.faxUUID)).subscribe(onSuccess: { (response) in
//
////                guard let self = self else { return }
//                let data = response.data
//                try! self.realm.write {
//                    claimItem.pdfData = data
//                }
//
//                return (true, data)
//
//            }) { (_) in
//                return (false, Data())
//                }.disposed(by: disposeBag)
//        }
//    }

    // PDF 저장
    public func saveClaimPDF(claimItem: ClaimItem, data: Data) {
        Async.main {
            try! self.realm.write {
                claimItem.pdfData = data
            }
        }
    }

    // 보험금 받음
    public func savePayoutClaim(claimItem: ClaimItem) {
        Async.main {
            try! self.realm.write {
                claimItem.stateEnum = .payout
                claimItem.payoutDate = Date()
            }
        }
    }

    // 간편청구
    public func getClaimSectionModel(claimList: Results<ClaimItem>, selectedIndex: Int) -> [ClaimSectionModel] {

        var model: [ClaimSectionModel] =
            [
                ClaimSectionModel(model: ClaimSectionID.section1,
                                   items: [
                                    ClaimModelItem(claimType: .headerDefault(title: "간편청구",
                                                                          description: "번거롭고 귀찮아서 포기했던 보험금 청구,\n이제 보맵으로 쉽고 빠르게 청구하세요.")),
                                    ClaimModelItem(claimType: .headerButton(buttonTitle: "간편청구 가이드")),
                                    ClaimModelItem(claimType: .empty(height: 20))
                    ]),
                ClaimSectionModel(model: ClaimSectionID.section2,
                                   items: [
                                    ClaimModelItem(claimType: .tabbar(list: ["간편청구", "진료이용내역"], selectedIndex:selectedIndex))
                    ])
        ]

        if claimList.count > 0 {

            for claimItem in claimList {

                guard let name = claimItem.insurance.name else { continue }

                var cItem: ClaimModelItem?
                switch claimItem.stateEnum {

                // 작성중
                case .creating: cItem = self.creatingClaim(claimItem)
                // 작성완료
                case .complete: cItem = self.completeClaim(claimItem)
                // 팩스전송중
                case .sendingFAX: cItem = self.sendingFAXClaim(claimItem)
                // 팩스접수 완료
                case .successFAX: cItem = self.successFAXClaim(claimItem)
                // 팩스접수 실패
                case .failFAX: cItem = self.failFAXClaim(claimItem)
                // 팩스접수 실패
                case .failFAXNumberCheck: cItem = self.failFAXNumberCheckClaim(claimItem)
                // 보험금 수령 확인
                case .checkPayout: cItem = self.checkPayoutClaim(claimItem)
                // 보험금 수령
                case .payout: cItem = self.payoutClaim(claimItem)
                // 보험금 미수령
                case .noPayout: cItem = self.noPayoutClaim(claimItem)
                // 알수없음
                case .none: break

                }

                if let item = cItem {
                    model.append(ClaimSectionModel(model: ClaimSectionID.section3,
                                                          items: [
                                                            ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0xefefef), leading: 20)),
                                                            item,
                                                            ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0xefefef), leading: 20))
                        ]))
                }

            }
        } else {

            model.append(ClaimSectionModel(model: ClaimSectionID.section3,
                                                    items: [
                                                        ClaimModelItem(claimType: .empty(height: 32)),
                                                        ClaimModelItem(claimType: .headerTitle(title: "간편청구\n내역이 없습니다".bdmSetting(customFont: Font.light.font(size: 32), height: 34, letterSpacing: -1.0, color: UIColor(rgb: 0x3c7ae5)))),
                                                        ClaimModelItem(claimType: .empty(height: 4)),
                                                        ClaimModelItem(claimType: .headerDescription(description: "- 한번에 여러 보험사 청구가 가능합니다.\n- 한번만 입력하시면 다음부턴 자동입력됩니다.\n- 치료기간 동안의 서류를 한번에 등록 가능합니다.".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))))

                ]))
        }

        return model
    }

    // 진료이용내역
    public func getClaimSectionModel(medicalHistoryList: Results<ClaimMedicalHistoryItem>, selectedIndex: Int) -> [ClaimSectionModel] {

        var model: [ClaimSectionModel] =
            [
                ClaimSectionModel(model: ClaimSectionID.section1,
                                   items: [
                                    ClaimModelItem(claimType: .headerDefault(title: "간편청구",
                                                                          description: "번거롭고 귀찮아서 포기했던 보험금 청구,\n이제 보맵으로 쉽고 빠르게 청구하세요.")),
                                    ClaimModelItem(claimType: .headerButton(buttonTitle: "간편청구 가이드")),
                                    ClaimModelItem(claimType: .empty(height: 20))
                    ]),
                ClaimSectionModel(model: ClaimSectionID.section2,
                                   items: [
                                    ClaimModelItem(claimType: .tabbar(list: ["간편청구", "진료이용내역"], selectedIndex:selectedIndex))
                    ])
        ]

        if medicalHistoryList.count > 0 {

            model.append(ClaimSectionModel(model: ClaimSectionID.section3,
                                                  items: [
                                                    ClaimModelItem(claimType: .empty(height: 8)),
                                                    ClaimModelItem(claimType: .medicalNoticeView(description: "보여지는 금액과 실제 금액은 다를 수 있습니다.".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x4d4d4d), underLine: true))),
                                                    ClaimModelItem(claimType: .empty(height: 8)),
                                                    ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0xefefef), leading: 20))
            ]))

            for medicalHistoryItem in medicalHistoryList {
                model.append(ClaimSectionModel(model: ClaimSectionID.section3,
                                                        items: [
                                                            ClaimModelItem(claimType: .empty(height: 20)),
                                                            self.getMedicalHistoryItem(medicalHistoryItem),
                                                            ClaimModelItem(claimType: .empty(height: 20)),
                                                            ClaimModelItem(claimType: .underLine(color: UIColor(rgb: 0xefefef), leading: 20))
                    ]))
            }

        } else {

            model.append(ClaimSectionModel(model: ClaimSectionID.section3,
                                                    items: [
                                                        ClaimModelItem(claimType: .empty(height: 32)),
                                                        ClaimModelItem(claimType: .headerTitle(title: "진료이용\n내역이 없습니다".bdmSetting(customFont: Font.light.font(size: 32), height: 34, letterSpacing: -1.0, color: UIColor(rgb: 0x3c7ae5)))),
                                                        ClaimModelItem(claimType: .empty(height: 4)),
                                                        ClaimModelItem(claimType: .headerDescription(description: "진료 이용 내역은 국민건강보험공단에서\n조회한 결과로, 약 2개월 이전 이용 내역부터\n최근 1년간의 정보만 보여집니다.".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4)))),
                                                        ClaimModelItem(claimType: .empty(height: 20)),
                                                        ClaimModelItem(claimType: .medicalNoticeView(description: "보여지는 금액과 실제 금액은 다를 수 있습니다.".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x4d4d4d), underLine: true)))

                ]))
        }

        return model
    }
}

extension ClaimMainWorker {

    private func responseFaxState(code: HttpResponseCode, json: JSON) {
        switch code {
        case .code2000:

            guard let dataArray = json["data"].array else { return }

            var resultList = [ClaimFaxStateModel]()
            for item in dataArray {
                resultList.append(ClaimFaxStateModel(item))
            }
            Async.main {
                self.updateFaxState(results: resultList)
            }

        default: break
        }
    }

    private func updateFaxState(results: [ClaimFaxStateModel]) {

        let realm = try! Realm()
        try! realm.write {

            let checkDate = Date().addingTimeInterval(-(86400 * 3))

            for result in results {
                guard let faxUUID = result.faxUuid else { continue }
                let predicate = NSPredicate(format: "faxUUID = %@", faxUUID)
                guard let savedItem = realm.objects(ClaimItem.self).filter(predicate).first else { continue }
                guard let sendType = result.faxSendType else { continue }
                guard let sendDate = result.faxSendDate else { continue }

                savedItem.state = sendType
                savedItem.faxSentDate = sendDate

                if checkDate > savedItem.date {
                    savedItem.stateEnum = .checkPayout
                }
            }
        }
    }
}

extension ClaimMainWorker {

    private func creatingClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "청구서 작성중".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        let subTitle = "- \(item.date.toString(format: DateFormatType.custom("yyyy.MM.dd")))".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = "수정하기".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func completeClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "청구서 작성 완료".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        let subTitle = "- \(item.date.toString(format: DateFormatType.custom("yyyy.MM.dd")))".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = "수정하기".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func sendingFAXClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "FAX 전송중".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        let subTitle = "- 전송까지 5분~10분이 소요됩니다.".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = NSAttributedString()

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func successFAXClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "FAX 전송완료".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        let subTitle = "- \(item.date.toString(format: DateFormatType.custom("yyyy.MM.dd")))".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = "추가서류 접수".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        let btnTitle2 = "동일내용 청구".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func failFAXClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "FAX 전송실패".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xff3d3d))

        let subTitle = "- 팩스 전송을 다시 시도해주세요.".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = "팩스 재전송".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func failFAXNumberCheckClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "FAX 전송실패".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xff3d3d))

        let subTitle = "- 팩스 수신번호를 확인해주세요.".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = "팩스 재전송".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func checkPayoutClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "수령확인".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xff3d3d))

        let subTitle = "- 보험금 수령을 확인해주세요.".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = "미수령".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        let btnTitle2 = "수령".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func payoutClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "보험금 수령".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xff3d3d))

        let subTitle = "- \(item.date.toString(format: DateFormatType.custom("yyyy.MM.dd")))".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = "동일내용 청구".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func noPayoutClaim(_ item: ClaimItem) -> ClaimModelItem {

        let title = "보험금 미수령".bdmSetting(customFont: Font.semiBold.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xff3d3d))

        let subTitle = "- \(item.date.toString(format: DateFormatType.custom("yyyy.MM.dd")))".bdmSetting(customFont: Font.medium.font(size: 12), height: 16, letterSpacing: -0.5, color: UIColor(rgb: 0xa4a4a4))

        let btnTitle1 = NSAttributedString()

        let btnTitle2 = "동일내용 청구".bdmSetting(customFont: Font.medium.font(size: 14), height: 20, letterSpacing: -0.5, color: UIColor(rgb: 0x070e1a))

        return ClaimModelItem(claimType: .claimInsListStatusView(title: title, subTitle: subTitle, btnTitle1: btnTitle1, btnTitle2: btnTitle2))
    }

    private func getMedicalHistoryItem(_ item: ClaimMedicalHistoryItem) -> ClaimModelItem {

        switch item.typeEnum {
        case .pharmacy:
            return ClaimModelItem(claimType: .medicalListView(typeImage: #imageLiteral(resourceName: "icBadgePharmacy"), place: item.place, type: "약제비", amount: item.getPriceFormat ?? "0", date: item.getDateString ?? ""))
        case .hospital:
            return ClaimModelItem(claimType: .medicalListView(typeImage: #imageLiteral(resourceName: "icBadgeHospital"), place: item.place, type: "진료비", amount: item.getPriceFormat ?? "0", date: item.getDateString ?? ""))
        case .none:
            return ClaimModelItem(claimType: .medicalListView(typeImage: #imageLiteral(resourceName: "icBadgeHospital"), place: item.place, type: "진료비", amount: item.getPriceFormat ?? "0", date: item.getDateString ?? ""))
        }
    }
}
