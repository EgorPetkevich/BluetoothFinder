//
//  CustomPageControl.swift
//  blekokofinder
//
//  Created by Developer on 28.06.25.
//

import SwiftUI

struct CustomPageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = .onbDesc
        control.isUserInteractionEnabled = false
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}
