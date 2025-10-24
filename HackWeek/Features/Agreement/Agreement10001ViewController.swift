//
//  Agreement10001ViewController.swift
//  HackWeek
//
//  Created by 彭瑞淋 on 2025/10/24.
//

import Foundation
import GLAgreement
import GLTrackingExtension
import GLCore
import SnapKit
import GLMP

@objc(Agreement10001ViewController)
class Agreement10001ViewController: AgreementChannelViewController {
    private var beginTime: Double = 0
    
    // MARK: - UI Elements
    private lazy var onboardingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "onboarding_1"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var agreementTextImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "agreement_text"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var sloganLabel: UILabel = {
        let label = UILabel()
        label.text = "Beauty flows with you."
        label.font = UIFont(name: "Avenir-Light", size: 18)
        label.textAlignment = .center
        label.textColor = UIColor(red: 1, green: 0.96, blue: 0.99, alpha: 0.7)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(agreementLabelTapped(_:)))
        label.addGestureRecognizer(tapGesture)
        return label
    }()
    
    private lazy var getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(GLMPLanguage.getStarted, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    deinit {
        GL().Tracking_Event("agreement_close", parameters: [GLT_PARAM_TIME: Int(CFAbsoluteTimeGetCurrent() - self.beginTime)])
    }
    
    override var group: String {
        set {}
        get { "10001" }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        self.beginTime = CFAbsoluteTimeGetCurrent()
        GL().Tracking_Event("agreement_open")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 设置按钮渐变背景
        setupButtonGradient()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 添加背景图
        let backgroundImageView = UIImageView(image: UIImage(named: "app_bg"))
        backgroundImageView.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImageView, at: 0)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 添加 onboarding 图片
        self.view.addSubview(onboardingImageView)
        onboardingImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            // 按照图片原始比例 750:1190 设置高度
            make.height.equalTo(onboardingImageView.snp.width).multipliedBy(1190.0 / 750.0)
        }
        
        // 添加按钮
        self.view.addSubview(getStartedButton)
        getStartedButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(54)
        }
        
        // 添加协议文案（在按钮上方）
        self.view.addSubview(agreementLabel)
        agreementLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(335)
            make.bottom.equalTo(getStartedButton.snp.top).offset(-20)
        }
        
        // 添加标语文本（在协议文案上方）
        self.view.addSubview(sloganLabel)
        sloganLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(335)
            make.bottom.equalTo(agreementLabel.snp.top).offset(-70)
        }
        
        // 添加协议文本图片（在标语文本上方）
        self.view.addSubview(agreementTextImageView)
        agreementTextImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(sloganLabel.snp.top).offset(-8)
        }
        
        // 设置协议文案
        setupAgreementText()
    }
    
    private func setupAgreementText() {
        let termsText = GLMPLanguage.agreement_terms_of_use
        let policyText = GLMPLanguage.agreement_privacy_policy
        let fullText = String(format: GLMPLanguage.agreement_by_tapping, termsText, policyText)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont(name: "Avenir", size: 12) ?? UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        // 为 Terms of Use 添加下划线
        if let termsRange = fullText.range(of: termsText) {
            let nsRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.714, green: 0.714, blue: 0.714, alpha: 1), range: nsRange)  // #B6B6B6
        }
        
        // 为 Privacy Policy 添加下划线
        if let policyRange = fullText.range(of: policyText) {
            let nsRange = NSRange(policyRange, in: fullText)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.714, green: 0.714, blue: 0.714, alpha: 1), range: nsRange)  // #B6B6B6
        }
        
        agreementLabel.attributedText = attributedString
    }
    
    private func setupButtonGradient() {
        // 移除旧的渐变层
        getStartedButton.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = getStartedButton.bounds
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.302, blue: 0.557, alpha: 1).cgColor,      // #ff4d8e
            UIColor(red: 0.655, green: 0.098, blue: 0.824, alpha: 1).cgColor   // #a719d2
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.cornerRadius = 12
        
        getStartedButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Actions
    
    @objc private func agreementLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = agreementLabel.attributedText else { return }
        
        let termsText = GLMPLanguage.agreement_terms_of_use
        let policyText = GLMPLanguage.agreement_privacy_policy
        let fullText = attributedText.string
        
        // 获取点击位置
        let location = gesture.location(in: agreementLabel)
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: agreementLabel.bounds.size)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = agreementLabel.numberOfLines
        textContainer.lineBreakMode = agreementLabel.lineBreakMode
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // 检查是否点击了 Terms of Use
        if let termsRange = fullText.range(of: termsText) {
            let nsRange = NSRange(termsRange, in: fullText)
            if NSLocationInRange(characterIndex, nsRange) {
                openTermsOfUse()
                return
            }
        }
        
        // 检查是否点击了 Privacy Policy
        if let policyRange = fullText.range(of: policyText) {
            let nsRange = NSRange(policyRange, in: fullText)
            if NSLocationInRange(characterIndex, nsRange) {
                openPrivacyPolicy()
                return
            }
        }
    }
    
    @objc private func getStartedTapped() {
        finishAction()
    }
    
    private func finishAction() {
        self.continueAction()
        self.dismiss(animated: false, completion: nil)
    }
}
