//
//  ClaimConfirmViewController.swift
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
import RxCocoa
import RxSwift

protocol ClaimConfirmDisplayLogic: class {
    func displaySectionModel(viewModel: ClaimConfirm.SectionItem.ViewModel)
}

class ClaimConfirmViewController: ClaimBaseViewController, ClaimConfirmDisplayLogic {
    var interactor: ClaimConfirmBusinessLogic?
    var router: (NSObjectProtocol & ClaimConfirmRoutingLogic & ClaimConfirmDataPassing)?

    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = ClaimConfirmInteractor()
        let presenter = ClaimConfirmPresenter()
        let router = ClaimConfirmRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        interactor?.getSectionModel()
        configure()
    }

    private let disposeBag = DisposeBag()

    public let models = BehaviorRelay<[ClaimSectionModel]>(value: [])

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var bottomBtn: UIButton! {
        didSet {
            bottomBtn.setDefaultBottomBtnAttribute()
        }
    }

    // MARK: Do something

    func displaySectionModel(viewModel: ClaimConfirm.SectionItem.ViewModel) {
        models.accept(viewModel.claimSectionModel)
    }
}

extension ClaimConfirmViewController {

    private func configure() {
        configureUI()
        configureRx()
    }

    private func configureUI() {

    }

    private func configureRx() {
        models.bind(to: cv.rx.items(dataSource: dataSource)).disposed(by: self.disposeBag)

        self.backBtn.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)

        self.closeBtn.rx.tap
            .subscribe(onNext: {
                //                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)

        self.bottomBtn.rx.tap
            .subscribe(onNext: {

                //                self.router?.routeToRequireDoc(segue: nil)
                self.router?.routeToSendFax(segue: nil)

            }).disposed(by: disposeBag)
    }
}
