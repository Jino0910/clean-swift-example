//
//  PDFViewerRouter.swift
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

@objc protocol PDFViewerRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol PDFViewerDataPassing {
    var dataStore: PDFViewerDataStore? { get }
}

class PDFViewerRouter: NSObject, PDFViewerRoutingLogic, PDFViewerDataPassing {
    weak var viewController: PDFViewerViewController?
    var dataStore: PDFViewerDataStore?

    // MARK: Routing

    //func routeToSomewhere(segue: UIStoryboardSegue?)
    //{
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}

    // MARK: Navigation

    //func navigateToSomewhere(source: PDFViewerViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}

    // MARK: Passing data

    //func passDataToSomewhere(source: PDFViewerDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}
