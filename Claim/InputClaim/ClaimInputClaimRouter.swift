//
//  ClaimInputClaimRouter.swift
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

@objc protocol ClaimInputClaimRoutingLogic {
    func routeToRequireDoc(segue: UIStoryboardSegue?)
//    func routeToPDFViewer(segue: UIStoryboardSegue?)
}

protocol ClaimInputClaimDataPassing {
    var dataStore: ClaimInputClaimDataStore? { get }
}

class ClaimInputClaimRouter: NSObject, ClaimInputClaimRoutingLogic, ClaimInputClaimDataPassing {
    weak var viewController: ClaimInputClaimViewController?
    var dataStore: ClaimInputClaimDataStore?

    // MARK: Routing

    func routeToRequireDoc(segue: UIStoryboardSegue?) {
        let vc = UIStoryboard.getVC(name: .claim, vcName: ClaimRequireDocViewController.identifier) as! ClaimRequireDocViewController
        navigateToRequireDoc(source: viewController!, destination: vc)
    }

    // MARK: Navigation

    func navigateToRequireDoc(source: ClaimInputClaimViewController, destination: ClaimRequireDocViewController) {
        source.show(destination, sender: nil)
    }

    // MARK: Passing data

    //func passDataToSomewhere(source: ClaimInputClaimDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}
