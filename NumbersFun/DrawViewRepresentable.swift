//
//  DrawViewRepresentable.swift
//  NumbersFun
//
//  Created by Дмитрий Куприянов on 7.03.25.
//

import SwiftUI

struct DrawViewRepresentable: UIViewRepresentable {
    @Binding var drawView: DrawView
    var selectedDigit: Int

    func makeUIView(context: Context) -> DrawView {
        return drawView
    }

    func updateUIView(_ uiView: DrawView, context: Context) {
        uiView.setNeedsDisplay()
    }
}
