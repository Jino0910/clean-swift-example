//
//  PDFViewerViewController.swift
//  Bomapp
//
//  Created by rowkaxl on 27/02/2019.
//  Copyright (c) 2019 Redvelvet Ventures Inc. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import RxCocoa
import RxSwift
import WebKit
import WKCookieWebView
import SwiftyJSON

protocol PDFViewerDisplayLogic: class {
    func displayPDFViewer(viewModel: PDFViewer.PDFItem.ViewModel)
}

class PDFViewerViewController: UIViewController, PDFViewerDisplayLogic {
    var interactor: PDFViewerBusinessLogic?
    var router: (NSObjectProtocol & PDFViewerRoutingLogic & PDFViewerDataPassing)?

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
        let interactor = PDFViewerInteractor()
        let presenter = PDFViewerPresenter()
        let router = PDFViewerRouter()
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

        interactor?.getPDFData()
        configure()
    }

    override func loadView() {
        super.loadView()

        let webView: WKCookieWebView =
            WKCookieWebView(frame: self.view.bounds,
                            configurationBlock: { (_) in
            })

        self.webBaseView.addSubview(webView)
        self.webBaseView.fillAutoLayout(webView)

        self.webView = webView
        self.webView?.wkNavigationDelegate = self
        self.webView?.uiDelegate = self
    }

    private let disposeBag = DisposeBag()

    private var webView: WKCookieWebView?

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var webBaseView: UIView!

    func displayPDFViewer(viewModel: PDFViewer.PDFItem.ViewModel) {

        guard let url = URL(string: viewModel.pdfURL) else { return }
        let request = URLRequest(url: url)
        self.webView?.load(request)
    }
}

extension PDFViewerViewController {

    private func configure() {
        configureUI()
        configureRx()
    }

    private func configureUI() {
        if #available(iOS 11.0, *) {
            webView?.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    private func configureRx() {

        self.closeBtn.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}

extension PDFViewerViewController: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            completionHandler()

        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (_) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (_) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LottieHUD.shared.showHUD()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        LottieHUD.shared.stopHUD()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error: error)

    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error: error)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        decisionHandler(.allow)
    }

    func handleError(error: Error) {
        LottieHUD.shared.stopHUD()
        if let failingUrl = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String {
            print(failingUrl)
            if let url = URL(string: failingUrl),
                !url.absoluteString.hasPrefix("http") {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    print($0)
                })
            }
        }
    }
}
