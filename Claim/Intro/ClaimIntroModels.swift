//
//  ClaimIntroModels.swift
//  Bomapp
//
//  Created by rowkaxl on 06/03/2019.
//  Copyright (c) 2019 Redvelvet Ventures Inc. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum ClaimIntro {
    // MARK: Use cases

    enum SectionItem {
        struct Request {

        }
        struct Response {
            var claimSectionModel: [ClaimSectionModel]
        }
        struct ViewModel {
            var claimSectionModel: [ClaimSectionModel]
        }
    }
}
