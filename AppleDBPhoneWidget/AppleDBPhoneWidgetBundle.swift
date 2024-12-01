//
//  AppleDBPhoneWidgetBundle.swift
//  AppleDBPhoneWidget
//
//  Created by Kane Parkinson on 12/06/2024.
//

import WidgetKit
import SwiftUI

@main
struct AppleDBPhoneWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        if #available(iOSApplicationExtension 16.1, *) {
            LeftSupaWidget()
            RightSupaWidget()
            SupaYearsWidget()
        }
        BDaySupaLeftWidget()
        BDaySupaRightWidget()
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return backgroundView
        }
    }
}
