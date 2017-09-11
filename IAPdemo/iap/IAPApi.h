//
//  IAPApi.h
//  IAPdemo
//
//  Created by Howe on 09/09/2017.
//  Copyright © 2017 Howe. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "InAppPurchase_oc.h"

@interface IAPApi : NSObject<IAPProtocol>
{
    BOOL _debugMode;
    BOOL _localVerify;
    
    InAppPurchase_oc * purchase_oc;
}
+(IAPApi*)Instance;

-(void)setDebugMode:(BOOL)isDebug;

-(void)buy:(NSString*)product verifyReceipt:(BOOL)verify;

-(void)getIAPProductList;

-(void)dispose;

@end
