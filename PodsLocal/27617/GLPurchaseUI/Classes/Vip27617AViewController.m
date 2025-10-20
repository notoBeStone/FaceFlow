//
//  Vip13138EViewController.m
//  Vip13138
//
//  Created by taow on 2021/3/22.
//

#import "Vip27617AViewController.h"
#import <DGMasonry/Masonry.h>
#import <GLPurchaseUI/GLPurchaseUI-Swift.h>
#import <GLPurchaseUI/GLPurchaseUtil.h>
#import <GLPurchaseUI/VipCommonLocalizable.h>
#import <GLRemoteResouce/UIImageView+RFP.h>
#import <GLPurchaseUI/GLPurchaseSpecification.h>
#import <Vip27617/Vip27617-Swift.h>
#import <UserNotifications/UserNotifications.h>
#import <GLTrackingExtension/GLTrackingParameters.h>
#import <GLAccountExtension/GLAccountExtension-Swift.h>
#import <GLCore/GLMediator.h>
#import <GLComponentAPI/GLAPIVipInfo.h>
#import <GLPurchaseExtension/GLPurchaseExtension-Swift.h>
#import <AVKit/AVKit.h>
#import <GLCore/GLMediator.h>
#import <GLUtils/GLUtils.h>
#import <GLTrackingExtension/GLTrackingExtension-Swift.h>
#import <GLConfig_Extension/GLConfig_Extension-Swift.h>
#import <GLResource/GLResource-Swift.h>
#import <GLResource/GLLanguage.h>

@import GLConfig_Extension;
@import GLTrackingExtension;

@interface Vip27617AViewController ()<Vip27617AContentViewDelegate>
@property (nonatomic, strong) Vip27617AContentView *contentView;
@end

@implementation Vip27617AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
}

- (void)configUI {
    self.view.backgroundColor = [UIColor colorFromHex:0x131023];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0.0);
    }];
}

- (void)updateUI {
    [self.contentView showPirce];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    [self.contentView layout];
}

- (UIButton *)getCloseButton {
    return self.contentView.cancelButton;
}

#pragma mark - methods
- (void)restoreAction {
    [self restore];
}

- (void)closeAction {
    [self trackingClose];
    [self cancel];
}

- (void)startAction:(enum Price27617Type)type {
    if (self.contentView.trailable) {
        NSString *title = [GLLanguage localizedOrMainForClass:self.class tableName:@"Localizable27617" key:@"conversionpage_pushnotification_title"];
        NSString *body = [GLLanguage localizedOrMainForClass:self.class
                                                   tableName:@"Localizable27617"
                                                         key:@"conversionpage_pushnotification_text", @"BeVocal"];
        [self reminderBuyWithSkuId:self.contentView.skuId offerId:nil title:title body:body];
    } else {
        [self buyWithSkuId:self.contentView.skuId];
    }
}

- (NSArray<NSString *> *)pageSkuIds {
    return Vip27617AContentView.skuIds;
}

- (void)termsOfUseAction {
    [self openTermsOfUse];
}

- (void)subscriptionAction {
    [GL() Tracking_Event:@"vip_subscriptionurl_click"];
    NSString *url = [[GL() GLConfig_GetMainHost] stringByAppendingString:@"/static/SubscriptionTerms_AppStore.html"];
    if ([self isInJapan]) {
        url = [[GL() GLConfig_GetMainHost] stringByAppendingString:@"/static/Japan/SubscriptionTerms_AppStore.html"];
    }
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}

- (void)privacyPolicyAction {
    [self openPrivacyPolicy];
}

- (BOOL)isInJapan {
    NSString *countryCode = [self countryCode];
    return [countryCode isEqualToString:@"JP"];;
}

- (NSString *)countryCode {
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = currentLocale.countryCode;
    if (!countryCode.length) {
        return @"US";
    }
    return countryCode;
}

- (Vip27617AContentView *)contentView {
    if (!_contentView) {
        _contentView = [[Vip27617AContentView alloc] initWithExtra:self.extra delegate:self];
    }
    return _contentView;
}
@end
