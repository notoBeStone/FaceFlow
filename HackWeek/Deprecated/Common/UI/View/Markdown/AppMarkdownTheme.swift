//
//  AppMarkdownTheme.swift
//  AINote
//
//  Created by user on 2024/9/4.
//

import Foundation
import MarkdownUI
import GLResource
import GLUtils
import SwiftUI

extension MarkdownUI.Theme {
    static let markdownTheme1 = Theme()
        .text {
            FontSize(16.rpx)
            FontWeight(.medium)
            ForegroundColor(.g8)
            FontFamily(.custom("Montserrat-Medium"))
        }
        .paragraph { configuration in
            configuration.label
                .fixedSize(horizontal: false, vertical: true)
                .relativeLineSpacing(.em(0.235295))
                .markdownMargin(top: .em(0.8), bottom: .zero)
                .markdownTextStyle {
                    FontFamily(.custom("Montserrat-Regular"))
                }
        }
//        .heading1 { configuration in
//            configuration.label
//                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
//                .markdownTextStyle {
//                    ForegroundColor(.g10)
//                    FontWeight(.bold)
//                    FontSize(.em(2))
//                    FontFamily(.custom("Avenir-Heavy"))
//                }
//        }
        .heading1 { configuration in
            configuration.label
                .markdownMargin(top: .rem(1.5), bottom: .rem(1))
                .markdownTextStyle {
                    ForegroundColor(.g10)
                    FontWeight(.bold)
                    FontSize(.em(1.5))
                    FontFamily(.custom("Montserrat-Bold"))
                }
        }
        .heading2 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.07143))
                .markdownMargin(top: .em(1.6), bottom: .zero)
                .markdownTextStyle {
                    ForegroundColor(.g10)
                    FontWeight(.bold)
                    FontSize(.em(1.25))
                    FontFamily(.custom("Montserrat-Medium"))
                }
        }
        .heading3 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.083335))
                .markdownMargin(top: .em(1.6), bottom: .zero)
                .markdownTextStyle {
                    ForegroundColor(.g10)
                    FontWeight(.bold)
                    FontSize(.em(1.125))
                    FontFamily(.custom("Montserrat-Medium"))
                }
        }
        .heading4 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.09091))
                .markdownMargin(top: .em(1.6), bottom: .zero)
                .markdownTextStyle {
                    ForegroundColor(.g9)
                    FontWeight(.semibold)
                    FontSize(.em(1.0))
                    FontFamily(.custom("Montserrat-Medium"))
                }
        }
        .heading5 { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.235295))
                .markdownMargin(top: .em(1.6), bottom: .zero)
                .markdownTextStyle {
                    ForegroundColor(.g10)
                    FontWeight(.regular)
                    FontFamily(.custom("Montserrat-Medium"))
                }
        }
}
