//
//  ClaimSelectInsuranceModels.swift
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
import SwiftyJSON

enum ClaimSelectInsurance {
    // MARK: Use cases

    enum CompList {
        struct Request {

        }
        struct Response {
            var json: JSON
        }
        struct ViewModel {
            var compList: [InsuranceCompModel]
            var claimSectionModel: [ClaimSectionModel]
        }
    }

    enum PDFData {
        struct Request {

        }
        struct Response {
            var json: JSON
        }
        struct ViewModel {
//            var pdfURL: String
        }
    }
}
