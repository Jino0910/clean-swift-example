//
//  ClaimSelectInsuranceRouter.swift
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

@objc protocol ClaimSelectInsuranceRoutingLogic {
    func routeToInputContact(segue: UIStoryboardSegue?)
//    func routeToPDFViewer(segue: UIStoryboardSegue?, pdfURL: String)
    func routeToPDFViewer(segue: UIStoryboardSegue?)
}

protocol ClaimSelectInsuranceDataPassing {
    var dataStore: ClaimSelectInsuranceDataStore? { get }
}

class ClaimSelectInsuranceRouter: NSObject, ClaimSelectInsuranceRoutingLogic, ClaimSelectInsuranceDataPassing {
    weak var viewController: ClaimSelectInsuranceViewController?
    var dataStore: ClaimSelectInsuranceDataStore?

//    guard let document = PDFDocument(url: pdfDocumentURL) else { return }
//    let vc = PDFViewController.createNew(with: document)
//    self.present(vc, animated: true, completion: nil)

    // MARK: Routing

    func routeToInputContact(segue: UIStoryboardSegue?) {
        let vc = UIStoryboard.getVC(name: .claim, vcName: ClaimInputContractViewController.identifier) as! ClaimInputContractViewController
        navigateToInputContact(source: viewController!, destination: vc)
    }

//    func routeToPDFViewer(segue: UIStoryboardSegue?, pdfURL: String) {
    func routeToPDFViewer(segue: UIStoryboardSegue?) {

        let vc = UIStoryboard.getVC(name: .claim, vcName: PDFViewerViewController.identifier) as! PDFViewerViewController
        var ds = vc.router!.dataStore!
//        passDataToPDFViewer(pdfURL: pdfURL, destination: &ds)
        passDataToPDFViewer(source: dataStore!, destination: &ds)
        navigateToPDFViewer(source: viewController!, destination: vc)
    }

    // MARK: Navigation

    func navigateToInputContact(source: ClaimSelectInsuranceViewController, destination: ClaimInputContractViewController) {
        source.show(destination, sender: nil)
    }

    func navigateToPDFViewer(source: ClaimSelectInsuranceViewController, destination: PDFViewerViewController) {
        source.present(destination, animated: true)
    }

    // MARK: Passing data

//    func passDataToPDFViewer(pdfURL: String, destination: inout PDFViewerDataStore) {
//        destination.pdfURL = pdfURL
//    }

    func passDataToPDFViewer(source: ClaimSelectInsuranceDataStore, destination: inout PDFViewerDataStore) {
        destination.pdfURL = source.pdfURL
    }
}
