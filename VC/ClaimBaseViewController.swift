//
//  ClaimBaseViewController.swift
//  Bomapp
//
//  Created by rowkaxl on 06/03/2019.
//  Copyright © 2019 Redvelvet Ventures Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import BomappDM
import RxDataSources
import SwiftyJSON

class ClaimBaseViewController: UIViewController {

    public var tabSelectHandler : ((_ selectedIndex: Int) -> Void)?
    public var buttonTabHandler : ((_ buttonTitle: String) -> Void)?
    public var categoryButtonHandler : ((_ categoryTitle: String) -> Void)?
    public var descriptionHandler : ((_ link: URL) -> Void)?
    public var textViewHeightHandler : ((_ height: CGFloat) -> Void)?

    public var claimButtonTabHandler : ((_ item: ClaimModelItem, _ buttonTitle: String) -> Void)?

    private let disposeBag = DisposeBag()

    public var dataSource: RxCollectionViewSectionedAnimatedDataSource<ClaimSectionModel>!

    @IBOutlet weak var cv: UICollectionView! {
        didSet {

            cv.registerCellNib(BDMEmptyCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMUnderLineCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMTitleDefaultCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMButtonOnlyCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMHeaderTitleCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMHeaderDescriptionCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMCategoryType1Cell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInputDefaultCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInputSelectCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInputSelectListCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInputTextViewCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInfoType1Cell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInfoType2Cell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMTabbarCell.self, bundle: BDMBundle)
            cv.registerCellNib(BDMInsuranceLogoTitleCell.self, bundle: BDMBundle)

            // 메인
            cv.registerCellNib(ClaimInsListStatusCell.self)
            cv.registerCellNib(MedicalNoticeCell.self)
            cv.registerCellNib(MedicalListCell.self)

            // 가이드
            cv.registerCellNib(GuideDescCell.self)

            // 보험사 리스트
            cv.registerCellNib(ClaimSelectInsuranceCell.self)

            // 구비서류 등록 안내
            cv.registerCellNib(ClaimDotDescCell.self)

            // 구비서류등록 리스트
            cv.registerCellNib(ClaimGalleyImageCell.self)
            cv.registerCellNib(ClaimAddImageCell.self)

            // 서명
            cv.registerCellNib(ClaimSignatureCell.self)

            let flowLayout: UICollectionViewFlowLayout! = UICollectionViewFlowLayout()
            flowLayout.sectionHeadersPinToVisibleBounds = true
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0

            cv.collectionViewLayout = flowLayout
            cv.showsVerticalScrollIndicator = false
            cv.showsHorizontalScrollIndicator = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    open override func loadView() {
        super.loadView()

        dataSource = RxCollectionViewSectionedAnimatedDataSource<ClaimSectionModel>(
            animationConfiguration: AnimationConfiguration(insertAnimation: UITableView.RowAnimation.fade,
                                                           reloadAnimation: UITableView.RowAnimation.fade,
                                                           deleteAnimation: UITableView.RowAnimation.fade),
            configureCell: self.configureCell)

    }
}

extension ClaimBaseViewController {

    private func configure() {
        configureUI()
    }

    private func configureUI() {
        cv.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
}

extension ClaimBaseViewController {

    private func configureCell(datasource: CollectionViewSectionedDataSource<ClaimSectionModel>,
                               cv: UICollectionView,
                               indexPath: IndexPath,
                               item: ClaimModelItem) -> UICollectionViewCell {

        switch item.claimType {

        case .empty:
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMEmptyCell", for: indexPath) as! BDMEmptyCell
            return cell
        case .underLine(let color, let leading):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMUnderLineCell", for: indexPath) as! BDMUnderLineCell
            cell.setting(underLineColor: color, underLineLeading: leading)
            return cell
        case .headerDefault(let title, let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMTitleDefaultCell", for: indexPath) as! BDMTitleDefaultCell
            cell.configure(title: title, desc: description)
            return cell
        case .headerTitle(let title):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMHeaderTitleCell", for: indexPath) as! BDMHeaderTitleCell
            cell.setting(title: title)
            return cell
        case .headerDescription(let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMHeaderDescriptionCell", for: indexPath) as! BDMHeaderDescriptionCell
            cell.setting(description: description)
            return cell
        case .headerButton(let buttonTitle):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMButtonOnlyCell", for: indexPath) as! BDMButtonOnlyCell
            cell.setting(title: buttonTitle) {
                guard let handler = self.buttonTabHandler else { return }
                handler(buttonTitle)
            }
            return cell
        case .infoCategoryType1(let title, let subTitle, let buttonTitle, let isHiddenButton):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMCategoryType1Cell", for: indexPath) as! BDMCategoryType1Cell
            cell.setting(title: title, subTitle: subTitle, btnTitle: buttonTitle, isHiddenButton: isHiddenButton) {
                guard let handler = self.categoryButtonHandler else { return }
                handler(title)
            }
            return cell
        case .inputDefault(let title, let placeholder, let lineColor):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMInputDefaultCell", for: indexPath) as! BDMInputDefaultCell
            cell.setting(title: title, placeholder: placeholder, text: item.value["text"].string)
            cell.underLine.backgroundColor = lineColor
            cell.inputField.rx
                .controlEvent(UIControl.Event.editingDidEnd)
                .asObservable()
                .subscribe(onNext: { [weak self] _ in
                    guard self != nil else { return }
                    guard let inputText = cell.inputField.text, !inputText.isEmpty else { return }
                    item.value["text"] = JSON(inputText)
                }).disposed(by: cell.disposeBag)
            return cell
        case .inputRadio(let title, let btns):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMInputSelectCell", for: indexPath) as! BDMInputSelectCell
            cell.setting(title: title, btns: btns, selectedIndex: item.value["index"].int) { [weak self] index in
                guard let self = self else { return }
                item.value["index"] = JSON(index)

                guard let handler = self.buttonTabHandler else { return }
                handler(btns[index])
            }
            return cell
        case .inputPicker(let title, let placeholder, let list, let underLineLeading):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMInputSelectListCell", for: indexPath) as! BDMInputSelectListCell
            cell.setting(title: title,
                         placeholder: placeholder,
                         text: item.value["text"].string,
                         list: list,
                         underLineLeading: underLineLeading) { [weak self] text in
                            guard self != nil else { return }
                            item.value["text"] = JSON(text)
            }
            return cell
        case .inputTextView(let title, let placeholder):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMInputTextViewCell", for: indexPath) as! BDMInputTextViewCell
            cell.setting(title: title, placeholder: placeholder, text: item.value["text"].string, maxLength: 300) { height in
                item.value["height"] = JSON(height)
                guard let handler = self.textViewHeightHandler else { return }
                handler(height)
            }
            cell.inputTextView.rx
                .didEndEditing
                .asObservable()
                .subscribe(onNext: { [weak self] _ in
                    guard self != nil else { return }
                    guard let inputText = cell.inputTextView.text, !inputText.isEmpty else { return }
                    item.value["text"] = JSON(inputText)
                }).disposed(by: cell.disposeBag)

            return cell
        case .infoType1(let title, let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMInfoType1Cell", for: indexPath) as! BDMInfoType1Cell
            cell.setting(title: title, description: description)
            return cell
        case .infoType2(let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMInfoType2Cell", for: indexPath) as! BDMInfoType2Cell
            cell.setting(info: description)
            return cell
        case .tabbar(let list, let index):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "BDMTabbarCell", for: indexPath) as! BDMTabbarCell
            cell.setting(tabList: list, selectedIndex: index) { [weak self] selectedIndex in
                guard let self = `self`,
                    let handler = self.tabSelectHandler else { return }
                handler(selectedIndex)
            }
            return cell
        case .insuranceLogoTitle(let logoNumber, let insuTitle, let isDisable, let buttonTitle, let buttonImage):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: BDMInsuranceLogoTitleCell.identifier, for: indexPath) as! BDMInsuranceLogoTitleCell
            cell.setting(logoNumber: logoNumber, insuTitle: insuTitle, isDisable: isDisable, buttonTitle: buttonTitle, buttonImage: buttonImage) {

                print("1")
            }
            return cell

        // 메인
        case .claimInsListStatusView(let title, let subTitle, let btnTitle1, let btnTitle2):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: ClaimInsListStatusCell.identifier, for: indexPath) as! ClaimInsListStatusCell
            cell.setting(title: title, subTitle: subTitle, buttonTitle1: btnTitle1, buttonTitle2: btnTitle2) { [weak self] (buttonTitle) in
                guard let self = self else { return }
                guard let handler = self.claimButtonTabHandler else { return }
                handler(item, buttonTitle)
            }
            return cell

        case .medicalNoticeView(let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: MedicalNoticeCell.identifier, for: indexPath) as! MedicalNoticeCell
            cell.setting(description: description) {
                guard let handler = self.buttonTabHandler else { return }
                handler(description.string)
            }
            return cell

        case .medicalListView(let typeImage, let place, let type, let amount, let date):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: MedicalListCell.identifier, for: indexPath) as! MedicalListCell
            cell.setting(typeImage: typeImage, place: place, type: type, amount: amount, date: date)
            return cell

        // 가이드
        case .guideDesc(let numImage, let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: GuideDescCell.identifier, for: indexPath) as! GuideDescCell
            cell.setting(numImg: numImage, description: description)
            return cell

        // 보험사 리스트
        case .compListView(let logoImage, let insName, let insCnt, let term, let availableFaxType):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: ClaimSelectInsuranceCell.identifier, for: indexPath) as! ClaimSelectInsuranceCell
            cell.setting(logoImage: logoImage, insName: insName, insCnt: insCnt, term: term, availableFaxType: availableFaxType) {
                guard let handler = self.claimButtonTabHandler else { return }
                handler(item, term)
            }
            return cell

        // 구비서류 등록 안내
        case .dotDesc(let description):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: ClaimDotDescCell.identifier, for: indexPath) as! ClaimDotDescCell
            cell.setting(description: description)
            return cell

        // 구비서류 등록 리스트
        case .galleryImage(let asset):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: ClaimGalleyImageCell.identifier, for: indexPath) as! ClaimGalleyImageCell
            cell.setting(assets: asset)
            return cell
        case .addImage:
            let cell = cv.dequeueReusableCell(withReuseIdentifier: ClaimAddImageCell.identifier, for: indexPath)
            return cell

        // 서명
        case .signatue:
            let cell = cv.dequeueReusableCell(withReuseIdentifier: ClaimSignatureCell.identifier, for: indexPath) as! ClaimSignatureCell
            return cell

        default: return UICollectionViewCell()
        }
    }
}

extension ClaimBaseViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let section = dataSource[indexPath.section]
        let item = section.items[indexPath.item]

        let width = UIScreen.main.bounds.width

        switch item.claimType {
        case .empty(let height):
            return CGSize(width: width, height: height)
        case .underLine:
            return CGSize(width: width, height: BDMUnderLineCell.cellHeight)
        case .headerDefault(let title, let description):
            return CGSize(width: width, height: BDMTitleDefaultCell.cellHeight(width: width, title: title, description: description))
        case .headerTitle(let title):
            return CGSize(width: width, height: BDMHeaderTitleCell.cellHeight(width: width, title: title))
        case .headerDescription(let description):
            return CGSize(width: width, height: BDMHeaderDescriptionCell.cellHeight(width: width, description: description))
        case .headerButton:
            return CGSize(width: width, height: BDMButtonOnlyCell.cellHeight)
        case .infoCategoryType1:
            return CGSize(width: width, height: BDMCategoryType1Cell.cellHeight)
        case .inputDefault:
            return CGSize(width: width, height: BDMInputDefaultCell.cellHeight)
        case .inputRadio:
            return CGSize(width: width, height: BDMInputDefaultCell.cellHeight)
        case .inputPicker:
            return CGSize(width: width, height: BDMInputDefaultCell.cellHeight)
        case .inputTextView:
            return CGSize(width: width, height: CGFloat(item.value["height"].floatValue))
        case .infoType1(_, let description):
            print(CGSize(width: width, height: BDMInfoType1Cell.cellHeight(width: width, description: description)))
            return CGSize(width: width, height: BDMInfoType1Cell.cellHeight(width: width, description: description))
        case .infoType2(let description):
            return CGSize(width: width, height: BDMInfoType2Cell.getHeight(width: width, info: description, topBottomMargin: 6))
        case .tabbar:
            return CGSize(width: width, height: BDMTabbarCell.cellHeight)
        case .insuranceLogoTitle:
            return CGSize(width: width, height: 62)
                //BDMInsuranceLogoTitleCell)

        // 메인
        case .claimInsListStatusView:
            return CGSize(width: width, height: ClaimInsListStatusCell.cellHeight)
        case .medicalNoticeView:
            return CGSize(width: width, height: MedicalNoticeCell.cellHeight)
        case .medicalListView:
            return CGSize(width: width, height: MedicalListCell.cellHeight)

        // 가이드
        case .guideDesc(_, let description):
            return CGSize(width: width, height: GuideDescCell.cellHeight(description: description))

        // 보험사 리스트
        case .compListView(_, _, let insCnt, _, _):
            return CGSize(width: width, height: ClaimSelectInsuranceCell.cellHeight(insCnt: insCnt))

        // 구비서류 등록 안내
        case .dotDesc:
            return CGSize(width: width, height: ClaimDotDescCell.cellHeight)

        // 구비서류 등록 리스트
        case .galleryImage:
            return ClaimGalleyImageCell.cellSize()
        case .addImage:
            return ClaimAddImageCell.cellSize()

        // 서명
        case .signatue:
            return CGSize(width: width, height: ClaimSignatureCell.cellHeight())

        default: return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let section = dataSource[section]
        guard let item = section.items.first else { return .zero }

        switch item.claimType {
        case .galleryImage, .addImage: return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        default: return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        let section = dataSource[section]
        guard let item = section.items.first else { return 0 }

        switch item.claimType {
        case .galleryImage, .addImage: return 5
        default: return 0
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        let section = dataSource[section]
        guard let item = section.items.first else { return 0 }

        switch item.claimType {
        case .galleryImage, .addImage: return 5
        default: return 0
        }
    }
}
