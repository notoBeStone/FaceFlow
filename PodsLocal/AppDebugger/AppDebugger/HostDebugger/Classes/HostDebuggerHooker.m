//
//  HostDebuggerHooker.m
//  AppDebugger
//
//  Created by xie.longyan on 2023/2/24.
//

#import "HostDebuggerHooker.h"
@import GLCore;
@import GLUtils;
@import GLConfig_Extension;
@import GLConfig;
#import <AppDebugger/AppDebugger-Swift.h>

/*
 HostDebuggerHooker 旨在修改客户端主 Host。hook的相关方法如下：
 - GLConfig - env
 - GLConfig_Extension - GLConfig_getServerAddress
 - GLConfig_Extension - GLConfig_GetMainHost
 
 注意：在切换相关 Host 时，env 也会相应发生改变；当切换到自定义 Host 时，env 会被自动切换为 Stage（或 Test，自行修改）。
 */

@implementation HostDebuggerHooker

@end


@implementation GLConfig (HostDebugger)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self gl_swizzleClassMethod:@selector(env) swizzledSelector:@selector(debugger_env)];
        }
    });
}

@end


@implementation GLMediator (HostDebugger)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [self gl_swizzleInstanceMethod:@selector(GLConfig_getServerAddress) swizzledSelector:@selector(degbugger_getServerAddress)];
            [self gl_swizzleInstanceMethod:@selector(GLConfig_GetMainHost) swizzledSelector:@selector(debugger_GetMainHost)];
        }
    });
}

- (NSString *)degbugger_getServerAddress {
    if (AppServerHostDebugger.serverAddress && AppServerHostDebugger.serverAddress.length > 0) {
        return AppServerHostDebugger.serverAddress;
    }
    return [self degbugger_getServerAddress];
}

- (NSString *)debugger_GetMainHost {
    if (AppServerHostDebugger.mainHost && AppServerHostDebugger.mainHost.length > 0) {
        return AppServerHostDebugger.mainHost;
    }
    return [self debugger_GetMainHost];
}

@end
