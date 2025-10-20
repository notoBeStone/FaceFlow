//
//  NetworkSignture.h
//  GLConfig
//
//  Created by User on 2020/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkSignture : NSObject

+ (NSString *)prod;

+ (NSString *)stage;

+ (NSString *)test;

@end

NS_ASSUME_NONNULL_END
