//
//  AlertType.swift
//  Benji
//
//  Created by Benji Dodgson on 12/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum AlertType: String {
    
    case error
    case warning
    case success

    var color: Color {
        switch self {
        case .error:
            return .red
        case .warning:
            return .orange
        case .success:
            return .green
        }
    }

    var icon: UIImage {
        switch self {
        case .error:
            return UIImage.init(systemName: "xmark.octagon.fill")!
        case .warning:
            return UIImage.init(systemName: "exclamationmark.triangle.fill")!
        case .success:
            return UIImage.init(systemName: "checkmark.seal.fill")!
        }
    }
}
