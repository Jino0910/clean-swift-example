//
//  ClaimNoPayoutViewController.swift
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

protocol ClaimNoPayoutDisplayLogic: class {
    func displaySomething(viewModel: ClaimNoPayout.Something.ViewModel)
}

class ClaimNoPayoutViewController: UIViewController, ClaimNoPayoutDisplayLogic {
    var interactor: ClaimNoPayoutBusinessLogic?
    var router: (NSObjectProtocol & ClaimNoPayoutRoutingLogic & ClaimNoPayoutDataPassing)?

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
        let interactor = ClaimNoPayoutInteractor()
        let presenter = ClaimNoPayoutPresenter()
        let router = ClaimNoPayoutRouter()
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
//        doSomething()

        setRX()
    }

    private let disposeBag = DisposeBag()

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bottomBtn: UIButton!

    // MARK: Do something

    //@IBOutlet weak var nameTextField: UITextField!

    func doSomething() {
        let request = ClaimNoPayout.Something.Request()
        interactor?.doSomething(request: request)
    }

    func displaySomething(viewModel: ClaimNoPayout.Something.ViewModel) {
        //nameTextField.text = viewModel.name
    }
}

extension ClaimNoPayoutViewController {

    func setRX() {

        self.backBtn.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        self.bottomBtn.rx.tap
            .subscribe(onNext: {

            }).disposed(by: disposeBag)
    }
}
