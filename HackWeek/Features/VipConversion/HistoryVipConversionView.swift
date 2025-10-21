//
//  HistoryVipConversionView.swift
//  AquaAI
//
//  Created by stephenwzl on 2025/7/1.
//

import SwiftUI
import StoreKit

let historyPaywallFeatures = [
    "Personalized makeup tutorials for your style",
    "Learn from professional makeup artists",
    "Scan products to analyze ingredient safety"
]

struct HistoryVipConversionView: View {
    @StateObject private var viewModel = VipConversionViewModel(memoType: "27622")
    @EnvironmentObject var conversionObserver: ConversionEventObserver
    // 是否是 iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // 安全区域顶部高度
    private var safeAreaTop: CGFloat {
        MediaQuery.safeArea.top
    }
    
    var headImage: some View {
        VipHeaderVideoPlayer(videoName: "vip_header", aspectRatio: 2250/1156)
    }
    
    var gradient: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        LinearGradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(1.0)
                        ], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: proxy.size.height / 1.5)
            }
        }
    }
    
    var titleArea: some View {
        VStack(spacing: 0) {
            (
                Text("Makeup Easier\nWith ")
                    .foregroundColor(Color(hex: 0x1A1A1A))
                +
                Text("FaceFlow")
                    .foregroundColor(.mainColor)
            )
            .font(.custom("Montserrat-Bold", size: isIPad ? 34 : 22))
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, isIPad ? 150 : 24)
    }
    
    var featureView: some View {
        VStack(spacing: 10) {
            ForEach(historyPaywallFeatures, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(.vipCheckIcon)
                        .resizable()
                        .frame(width: isIPad ? 24 : 16, height: isIPad ? 24 : 16)
                    Text(item)
                        .font(.custom("Montserrat-Medium", size: isIPad ? 20 : 16))
                        .foregroundColor(Color(hex: 0x3B3B3B))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.top, isIPad ? 24 : 16)
    }
    
    var skuSelectionView: some View {
        HStack(spacing: isIPad ? 12 : 8) {
            if viewModel.skus.isEmpty {
                templateSkuItemView
                templateSkuItemView
            } else {
                ForEach(viewModel.skus) { sku in
                    skuItemView(sku: sku, isSelected: viewModel.selectedSkuId == sku.skuId)
                        .onTapGesture {
                            viewModel.selectSku(sku.skuId)
                        }
                }
            }
        }
    }
    
    var templateSkuItemView: some View {
        HStack {
            VStack(spacing: 3) {
                Text("--")
                    .fontSemiBold(18.rpx)
                    .color(Color(hex: 0x3B3B3B))
                    .blockLeading
                Text("--")
                    .fontMedium(16.rpx)
                    .color(Color(hex: 0x6C6C6C))
                    .blockLeading
            }
            Image(.vipUnselectIcon)
                .resizableSquare(24.rpx)
        }
        .pv(18)
        .ph(16)
        .block()
        .roundedBG(12, color:.clear)
        .roundedBorder(12, color: Color(hex: 0xD8D8D8))
    }
    
    @ViewBuilder
    private func skuItemView(sku: ConversionSku, isSelected: Bool) -> some View {
        HStack {
            VStack(spacing: 3) {
                Text(sku.trialDays > 0 ? "Free" : priceString(for: sku.product))
                    .fontSemiBold(18.rpx)
                    .color(isSelected ? .mainColor : Color(hex: 0x3B3B3B))
                    .blockLeading
                Text(sku.trialDays > 0 ? "\(sku.trialDays) days" : periodString(for: sku.period))
                    .fontMedium(16.rpx)
                    .color(isSelected ? .mainColor : Color(hex: 0x6C6C6C))
                    .blockLeading
            }
            Image(isSelected ? .vipSelectIcon : .vipUnselectIcon)
                .resizableSquare(24.rpx)
        }
        .pv(18)
        .ph(16)
        .block()
        .roundedBG(12, color: isSelected ? .mainColor.opacity(0.08) : .clear)
        .roundedBorder(12, color: isSelected ? .mainColor : Color(hex: 0xD8D8D8))
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
            Text(hintForSku(sku: item))
                .fontSemiBold(isIPad ? 20 : 14)
                .foregroundColor(Color(hex: 0x6C6C6C))
                .blockCenter
                .anyView
        } else {
            EmptyView().anyView
        }
    }
    
    var reminderView: some View {
        if let skuId = viewModel.selectedSkuId, let item = viewModel.skus.first(where: { $0.id == skuId}), item.trialDays > 0 {
            HStack(spacing: 8) {
                Image(.vipReminderIcon).resizableSquare(24.rpx)
                Text("Remind me before my trial ends")
                    .fontMedium(isIPad ? 16 : 14)
                    .foregroundColor(Color(hex: 0x3B3B3B))
                    .blockLeading
                    .lineLimit(1)
            }
            .pr(50)
            .overlay(alignment: .trailing, content: {
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
            })
            .anyView
        } else {
            EmptyView().anyView
        }
    }
    
    func hintForSku(sku: ConversionSku) -> String {
        if sku.trialDays > 0 {
            return "FREE FOR \(sku.trialDays) DAYS.THEN \(priceString(for: sku.product))/WEEK"
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
                .capsuleBG(.mainColor)
        }
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
            Button("Subscription Terms", action: viewModel.openTerms)
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
        VStack(spacing: 0) {
            headImage
                .overlay(gradient, alignment: .bottom)
                .overlay(titleArea, alignment: .bottom)
                .padding(.bottom, isIPad ? 20 : 12)
            
            VStack(spacing: 0) {
                featureView
                skuSelectionView
                    .pt(isIPad ? 60 : 24  )
                reminderView
                    .pt(isIPad ? 26 : 16)
                Spacer()
                VStack(spacing: 0) {
                    purchaseHint
                        .pb(isIPad ? 20 : 12)
                    purchaseButton
                        .pb(isIPad ? 56 : 16)
                    termsAndPolicyView
                }
            }
            .padding(.horizontal, isIPad ? 150 : 24)
        }
        .pb(20)
        .background(Color.white)
        .ignoresSafeArea()
        .onReceive(conversionObserver.updateUIEvent) { _ in
            TemplateAPI.Conversion.enableCurrentSkus(viewModel.availableSkus)
            Task {
                await viewModel.fetchSkus()
            }
        }
        .onAppear {
            TemplateAPI.Conversion.enableCurrentSkus(viewModel.availableSkus)
            Task {
                await viewModel.fetchSkus()
            }
        }
    }
}

#Preview {
    HistoryVipConversionView()
        .environmentObject(ConversionEventObserver())
}
