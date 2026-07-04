//
//  ImageCompressing.swift
//  TaggoMain
//
//  Created by Xaviero Yamin Loganta on 05/07/26.
//

import Foundation

protocol ImageCompressing: Sendable {
    func compress(_ data: Data, maxDimensionPixels: CGFloat, jpegQUality: CGFloat) throws -> Data;
}
