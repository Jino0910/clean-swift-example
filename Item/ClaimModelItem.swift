//
//  ClaimModelItem.swift
//  Bomapp
//
//  Created by rowkaxl on 05/03/2019.
//  Copyright © 2019 Redvelvet Ventures Inc. All rights reserved.
//

import Foundation
import RxDataSources
import SwiftyJSON
import Photos

// SectionModel 지정
public typealias ClaimSectionModel = ClaimAnimatableSectionModel<ClaimSectionID, ClaimModelItem>

// Section 구분
public enum ClaimSectionID: String, IdentifiableType {

    public var identity: String {
        return self.rawValue
    }

    case section1
    case section2
    case section3
    case section4
    case section5
    case section6
    case section7

}

// Row & item 구분
public class ClaimModelItem: IdentifiableType, Equatable {

    public enum ClaimType {

        /// MARK: Basic
        /// 공백 M_B_(N)
        case empty(height:CGFloat)
        /// 언더라인 (M_divider_l_gray) OR (M_divider_l_red) OR (M_divider_l_dark)
        case underLine(color:UIColor, leading:CGFloat)

        /// MARK: Header
        /// 타이틀뷰 M_title_default
        case headerDefault(title:String, description:String)
        /// 헤더 타이틀 M_display_title
        case headerTitle(title:NSAttributedString)
        /// 헤더 디스크립션 M_display_subcap
        case headerDescription(description:NSAttributedString)
        /// 헤더 버튼 M_text_link_b
        case headerButton(buttonTitle:String)

        /// MARK: Input
        /// 기본 입력필드 M_input_guide + M_divider_l_gray
        case inputDefault(title:String, placeholder:String, lineColor:UIColor)
        /// 기본 선택필드 M_input_radio
        case inputRadio(title:String, btnTitles:[String])
        /// 기본 선택 리스트 필드 M_input_dropdown_1_guide
        case inputPicker(title:String, placeholder:String, list:[String], underLineLeading:CGFloat)
        /// textView 입력필드 M_input_guide + M_B_20 + M_input_counting_b
        case inputTextView(title:String, placeholder:String)

        /// MARK: Info
        /// 카테고리
        case infoCategoryType1(title:String, subTitle:NSAttributedString, buttonTitle:String, isHiddenButton:Bool)
        /// info type 1 ( M_report_default_1 )
        case infoType1(title:String, description:String)
        case infoType2(description:NSAttributedString)
        /// M_note_default
        case infoDescriptionType(description:NSAttributedString)

        /// MARK: Tabbar
        /// 기본 텝바
        case tabbar(list:[String], selectedIndex:Int?)

        case insuranceLogoTitle(logoNumber: String, insuTitle: String, isDisable: Bool, buttonTitle: NSAttributedString?, buttonImage: UIImage?)

        /// MARK: Claim Main
        case claimInsListStatusView(title: NSAttributedString, subTitle: NSAttributedString, btnTitle1: NSAttributedString, btnTitle2: NSAttributedString)
        case medicalNoticeView(description: NSAttributedString)
        case medicalListView(typeImage: UIImage, place: String, type: String, amount: String, date: String)

        /// MARK: Claim Guide
        case guideDesc(numImage: UIImage, description: String)

        /// MARK: 보험사 리스트
        case compListView(logoImage: UIImage, insName: String, insCnt: String, term: String, availableFaxType: Bool)

        /// MARK: 구비서류등록 안내
        case dotDesc(description: NSAttributedString)

        /// MARK: 구비서류등록 리스트
        case galleryImage(asset: PHAsset)
        case addImage()

        /// MARK: 서명
        case signatue(description: String)
    }

    public var claimType: ClaimType
    public var value: JSON

    public init(claimType: ClaimType, value: JSON = JSON([:])) {
        self.claimType = claimType
        self.value = value
    }

    // IdentifiableType property
    public var identity: String {
        switch claimType {

        case .empty:
            return "empty" + UUID().uuidString

        case .headerDefault(let title, let description):
            return "titleDefault_\(title)_\(description)"
        case .inputDefault(let title, let placeholder, _):
            return "inputDefault_\(title)_\(placeholder)"
        case .inputRadio(let title, _):
            return "inputSelect_\(title)"

        case .inputPicker(let title, let placeholder, let list, _):
            return "inputSelectList_\(title)_\(placeholder)_\(list.joined(separator: ","))"
        case .inputTextView(let title, _):
            return "inputTextView_\(title)"

        case .underLine:
            return "underLine" + UUID().uuidString

        case .headerTitle(let title):
            return "headerTitle_\(title)"
        case .headerDescription(let description):
            return "headerDescription_\(description.string)"
        case .headerButton(let buttonTitle):
            return "headerButton\(buttonTitle)"
        case .infoCategoryType1(let title, _, let buttonTitle, _):
            return "categoryType1\(title)_\(buttonTitle)"
        case .infoType1(let title, let description):
            return "infoType1\(title)_\(description)"
        case .infoType2(let description):
            return "infoType2\(description.string)"
        case .infoDescriptionType(let description):
            return "descriptionType_\(description.string)"
        case .tabbar:
            return "tabbar"
        case .insuranceLogoTitle(let logoNumber, let insuTitle, _, _, _):
            return "insuranceLogoTitle_\(logoNumber)_\(insuTitle)"

        case .claimInsListStatusView(let title, let subTitle, let btnTitle1, let btnTitle2):
            return "claimInsListStatusView_\(title.string)_\(subTitle.string)_\(btnTitle1.string)_\(btnTitle2.string)"
        case .medicalNoticeView(let description):
            return "medicalNoticeView_\(description.string)"
        case .medicalListView(_, let place, let type, let amount, let date):
            return "medicalListView_\(place)_\(type)_\(amount)_\(date)"
        case .guideDesc(_, let description):
            return "guideDesc_\(description)"

        case .compListView(_, let insName, let insCnt, let term, _):
            return "compListView_\(insName)_\(insCnt)_\(term)"

        case .dotDesc(let description):
            return "dotDesc_\(description.string)"

        case .galleryImage:
            return "galleryImage" + UUID().uuidString
        case .addImage:
            return "addImage" + UUID().uuidString
        case .signatue(let description):
            return "signatue_\(description)"
        }

    }

    public static func == (lhs: ClaimModelItem, rhs: ClaimModelItem) -> Bool {
        return lhs.identity == rhs.identity
    }

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

public class ClaimAnimatableSectionModel<Section: IdentifiableType, ItemType: IdentifiableType & Equatable> {
    public var model: Section
    public var items: [Item]

    public init(model: Section, items: [ItemType]) {
        self.model = model
        self.items = items
    }

    public required init(original: ClaimAnimatableSectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }

}

extension ClaimAnimatableSectionModel: AnimatableSectionModelType {
    public typealias Item = ItemType
    public typealias Identity = Section.Identity

    public var identity: Section.Identity {
        return model.identity
    }

    public var hashValue: Int {
        return self.model.identity.hashValue
    }
}

extension ClaimAnimatableSectionModel: CustomStringConvertible {

    public var description: String {
        return "HashableSectionModel(model: \"\(self.model)\", items: \(items))"
    }

}
