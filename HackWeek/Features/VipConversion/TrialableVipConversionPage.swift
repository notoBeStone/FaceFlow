//
//  VipConversionView.swift
//  AquaAI
//
//  Created by stephenwzl on 2025/6/9.
//

import SwiftUI
import StoreKit

let paywallFeatures1 = [
    "Enjoy your first 3 days, it's free",
    "Cancel from the app or your iCloud account",
    "Personalized makeup tutorials for your style",
    "Learn from professional makeup artists",
    "Scan products to analyze ingredient safety"
]

let paywallFeatures2 = [
    "Enjoy your first week, it's affordable",
    "Cancel from the app or your iCloud account",
    "Personalized makeup tutorials for your style",
    "Learn from professional makeup artists",
    "Scan products to analyze ingredient safety"
] 


struct TrialableVipConversionPage: View {
    @StateObject private var viewModel = VipConversionViewModel(memoType: "27621")
    @EnvironmentObject var conversionObserver: ConversionEventObserver
    @State var isAnimating = false
    // 是否是 iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // 安全区域顶部高度
    private var safeAreaTop: CGFloat {
        MediaQuery.safeArea.top
    }
    
    var headImage: some View {
        Image("vip_header")
            .resizable()
            .aspectRatio(2502/1656, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()
    }
    
    var gradient: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(colors: [
                            Color(hex: 0x181920).opacity(0.0),
                            Color(hex: 0x181920).opacity(1.0)
                        ], startPoint: .center, endPoint: .bottom)
                    )
                    .frame(height: proxy.size.height / 1.5)
            }
        }
    }
    
    var titleArea: some View {
        Text("Design Your Trial")
            .fontBold(isIPad ? 44 : 24)
            .foregroundColor(.white)
            .blockCenter
    }
    
    var featureView: some View {
        let features: [String] = viewModel.selectedSkuId == viewModel.availableSkus[1] ? paywallFeatures2 : paywallFeatures1
        return VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 10) {
                    Image(.vipCheckIcon)
                        .renderingMode(.template)
                        .resizableSquare(isIPad ? 24 : 16)
                        .foregroundColor(.mainColor)
                    
                    Text(item)
                        .font(.custom("Montserrat-Medium", size: isIPad ? 22 : 16))
                        .foregroundColor(Color(hex: 0xE6E6E6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .pv(6)
                .fadeIn(1 + index, isAnimating: isAnimating)
            }
        }
        .padding(.top, 12)
    }
    
    var skuSelectionView: some View {
        HStack(spacing: 12) {
            if viewModel.skus.isEmpty {
                templateSkuItemView()
                templateSkuItemView(isLeading: false)
            } else {
                ForEach(Array(viewModel.skus.enumerated()), id: \.offset) { index, sku in
                    skuItemView(sku: sku, isSelected: viewModel.selectedSkuId == sku.skuId, isLeading: index == 0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectSku(sku.skuId)
                        }
                }
            }
        }
        .overlay(alignment: .center) {
            if viewModel.skus.isEmpty == false {
                Rectangle().fill(Color(hex: 0xFF4D8E))
                    .width(1)
            }
        }
    }
    
    func templateSkuItemView(isLeading: Bool = true) -> some View {
        HStack(alignment: .top) {
            VStack(spacing: 3) {
                Text("--")
                    .fontBold(isIPad ? 20 : 16)
                    .color(Color(hex: 0x3B3B3B))
                    .blockLeading
                Text("--")
                    .fontMedium(isIPad ? 14 : 12)
                    .color(Color(hex: 0x6C6C6C))
                    .blockLeading
                Spacer()
            }
            Image(systemName: "circle")
                .resizable()
                .frame(width: isIPad ? 28 : 24, height: isIPad ? 28 : 24)
                .foregroundColor(Color(hex: 0x464646))
        }
        .pv(isIPad ? 16 : 10)
        .ph(isIPad ? 16 : 12)
        .block()
        .frame(height: isIPad ? 110 : 77)
        .overlay {
            RoundedCorner(radius: 6)
                .stroke(Color(hex: 0x464646), lineWidth: 1)
        }
    }
    
    @ViewBuilder
    private func skuItemView(sku: ConversionSku, isSelected: Bool, isLeading: Bool = true) -> some View {
        HStack(alignment: .top) {
            VStack(spacing: 3) {
                Text(sku.trialDays > 0 ? "Free" : "1 week")
                    .fontBold(isIPad ? 20 : 16)
                    .color(isSelected ? .white : Color.white.opacity(0.6))
                    .blockLeading
                Text(sku.trialDays > 0 ? "\(sku.trialDays) days" : discountPrice(for: sku.product))
                    .fontMedium(isIPad ? 14 : 12)
                    .color(isSelected ? .white : Color.white.opacity(0.6))
                    .blockLeading
                Spacer()
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: isIPad ? 28 : 24, height: isIPad ? 28 : 24)
                .foregroundColor(isSelected ? Color(hex: 0xFF4D8E) : Color(hex: 0x464646))
        }
        .pv(isIPad ? 16 : 10)
        .ph(isIPad ? 16 : 12)
        .block()
        .frame(height: isIPad ? 110 : 77)
        .frame(maxWidth: .infinity)
        .background {
            RoundedCorner(radius: 6)
                .fill(isSelected ? Color(hex: 0xFF4D8E).opacity(0.35) : Color.clear)
        }
        .overlay {
            RoundedCorner(radius: 6)
                .stroke(isSelected ? Color(hex: 0xFF4D8E) : Color(hex: 0x464646), lineWidth: 1)
                .padding(0.5)
        }
    }
    
    private func discountPrice(for sku: SKProduct) -> String {
        if let priceLocale = sku.introductoryPrice?.priceLocale, let price = sku.introductoryPrice?.price {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = priceLocale
            return formatter.string(from: price) ?? ""
        }
        return ""
    }
    
    private func periodString(for period: ConversionSku.SkuPeriod) -> String {
        switch period {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .yearly: return "1 year"
            case .seasonly: return "Seasonal"
            case .halfYearly: return "6 Months"
            case .none: return ""
        }
    }
    
    private func priceString(for product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
    var purchaseHint: some View {
        if let skuId = viewModel.selectedSkuId, let item = viewModel.skus.first(where: { $0.id == skuId}) {
            if item.trialDays > 0 {
                (
                    Text("\(item.trialDays) days free, then just ")
                        .fontRegular(isIPad ? 20 : 14)
                    +
                    Text(priceString(for: item.product))
                        .fontBold(isIPad ? 22 : 16)
                    +
                    Text("/week")
                        .fontRegular(isIPad ? 20 : 14)
                )
                .foregroundColor(Color(hex: 0xE1E1E1))
                .anyView
            } else {
                (
                    Text("1st week \(discountPrice(for: item.product)), then just ")
                        .fontRegular(isIPad ? 20 : 14)
                    +
                    Text(priceString(for: item.product))
                        .fontBold(isIPad ? 22 : 16)
                    +
                    Text("/week")
                        .fontRegular(isIPad ? 20 : 14)
                )
                .foregroundColor(Color(hex: 0xE1E1E1))
                .anyView
            }
        } else {
            EmptyView().anyView
        }
    }
    
    var reminderView: some View {
        HStack(spacing: 8) {
            Text("Remind me before my trial ends")
                .fontMedium(isIPad ? 16 : 14)
                .foregroundColor(Color(hex: 0xE1E1E1))
                .blockLeading
                .lineLimit(1)
            Toggle(isOn: Binding(get: { viewModel.reminderEnable }, set: { newValue in
                TemplateAPI.Conversion.changeReminder(to: newValue) { granted in
                    DispatchQueue.main.async {
                        viewModel.reminderEnable = granted && newValue
                    }
                }
            })) {
                EmptyView()
            }
            .tint(.mainColor)
            .scaleEffect(0.8)
            .width(50)
        }
        .pv(8)
        .ph(16)
        .capsuleBorder(Color.white.opacity(0.29))
    }
    
    func hintForSku(sku: ConversionSku) -> String {
        if sku.trialDays > 0 {
            return "\(sku.trialDays) days free.then just \(priceString(for: sku.product))/week"
        }
        if sku.period == .weekly {
            return "JUST \(priceString(for: sku.product))/WEEK, LESS THAN \(sku.product.multyPrice(by: 1.0/7.0))/DAY"
        }
        if sku.period == .yearly {
            return "JUST \(priceString(for: sku.product))/YEAR, LESS THAN \(sku.product.multyPrice(by: 1.0/365))/DAY"
        }
        return ""
    }
    
    var purchaseButton: some View {
        Button(action: viewModel.purchaseButtonTapped) {
            Text("Continue")
                .fontSemiBold(isIPad ? 30 : 20)
                .foregroundColor(.white)
                .blockCenter
                .height(isIPad ? 76 : 56)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 1, green: 0.3, blue: 0.56), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.65, green: 0.1, blue: 0.82), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0, y: 0.5),
                        endPoint: UnitPoint(x: 1, y: 0.5)
                    )
                )
                .clipShape(Capsule())
        }
        .opacity(viewModel.selectedSkuId == nil ? 0.3 : 1.0)
        .disabled(viewModel.selectedSkuId == nil)
    }
    
    var termsAndPolicyView: some View {
        HStack(spacing: 4) {
            Button("Terms of Use", action: viewModel.openTerms)
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: 0xA4A4A4))
            Rectangle()
                .fill(Color(hex: 0xA4A4A4))
                .frame(width: 1, height: 8)
            Button("Privacy Policy", action: viewModel.openPrivacy)
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: 0xA4A4A4))
            Rectangle()
                .fill(Color(hex: 0xA4A4A4))
                .frame(width: 1, height: 8)
            Button("Subscription Terms", action: viewModel.openSubscriptionTerms)
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: 0xA4A4A4))
            Rectangle()
                .fill(Color(hex: 0xA4A4A4))
                .frame(width: 1, height: 8)
            Button("Restore", action: viewModel.restoreButtonTapped)
                .font(.system(size: 10))
                .foregroundStyle(Color(hex: 0xA4A4A4))
            
        }
        .font(.system(size: isIPad ? 14 : 12))
        .foregroundColor(.secondary)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headImage
                    .overlay(gradient, alignment: .bottom)
                Spacer()
            }
            .pb(20)
            
            VStack(spacing: 0) {
                Spacer(minLength: MediaQuery.screenSize.width / (isIPad ? 834/552 : 375/360) - 100)
                titleArea
                    .fadeIn(0, isAnimating: isAnimating)
                featureView
                skuSelectionView
                    .pt(isIPad ? 32 : 20 )
                    .fadeIn(6, isAnimating: isAnimating)
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        purchaseHint
                            .pb(isIPad ? 20 : 12)
                    }
                    .fadeIn(7, isAnimating: isAnimating)
                        
                    purchaseButton
                        .fadeIn(8, isAnimating: isAnimating)
                    reminderView
                        .fadeIn(9, isAnimating: isAnimating)
                        .pt(isIPad ? 18 : 12)
                        .pb(16)
                    termsAndPolicyView
                        .fadeIn(10, isAnimating: isAnimating)
                        .pb(isIPad ? 60 : 20)
                }
            }
            .padding(.horizontal, isIPad ? 150 : 20)
        }
        .ignoresSafeArea()
        .background(Color(hex: 0x181920))
        .onReceive(conversionObserver.updateUIEvent) { _ in
            TemplateAPI.Conversion.enableCurrentSkus(viewModel.availableSkus)
            Task {
                await viewModel.fetchSkus()
            }
        }
        .onAppear {
            isAnimating = true
            TemplateAPI.Conversion.enableCurrentSkus(viewModel.availableSkus)
            Task {
                await viewModel.fetchSkus()
            }
        }
    }
}

#Preview {
    TrialableVipConversionPage()
        .environmentObject(ConversionEventObserver())
}

extension View {
    func fadeIn(_ delayIndex: Int, isAnimating: Bool) -> some View {
        return self.opacity(isAnimating ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.5).delay(Double(delayIndex) * 0.2), value: isAnimating)
    }
}
