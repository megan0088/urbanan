//
//  TaggoStyle.swift
//  urbanan
//
//  Created by Muhamad Ega Nugraha on 07/07/26.
//

// TaggoStyle.swift
// File baru — tempat semua konstanta visual supaya tidak hardcode di mana-mana

import SwiftUI

// 👉 Tulis extension Color untuk shortcut warna Taggo
extension Color {
    static var taggoBlue = Color("TaggoBlue")
    static var taggoBlueLight = Color("TaggoBlueLight")
    static var taggoBackground = Color("TaggoBackground")
}

// 👉 Tulis konstanta ukuran yang sering dipakai
enum TaggoSpacing {
    static let cardCornerRadius: CGFloat = 16
    static let horizontalPadding: CGFloat = 20
}
