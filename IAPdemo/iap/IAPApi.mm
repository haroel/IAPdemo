//
//  IAPApi.m
//  IAPdemo
//
//  Created by Howe on 09/09/2017.
//  Copyright © 2017 Howe. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "IAPApi.h"
#import "InAppPurchase_oc.h"
#import "IAPMsgHandler.h"
#import "IAPDefine.h"

static IAPApi *_shareIap = nil;

@implementation IAPApi

+(IAPApi*)Instance
{
    if (_shareIap == nil){
        _shareIap = [[IAPApi alloc] init];
        [_shareIap initIAP];
    }
    return _shareIap;
}

-(void) initIAP
{
    _debugMode = FALSE;
    _localVerify = FALSE;
    
    purchase_oc = [InAppPurchase_oc alloc];
    purchase_oc.delegate = self;
    [purchase_oc initIAP];
}
-(void)setDebugMode:(BOOL)isDebug{
    _debugMode = isDebug;
}

-(void)buy:(NSString*)product verifyReceipt:(BOOL)verify{
    _localVerify = verify;
    [purchase_oc buy:product];
}

-(void)getIAPProductList{
    
}

-(void)errorCall:(int)code andErrorMsg:(NSString*)error{
    IAPMsgHandler::getInstance()->handlerData(code,[error UTF8String]);
}

-(void)productListCall:(int)code andParams:(NSString*)params{
    IAPMsgHandler::getInstance()->handlerData(code,[params UTF8String]);
}

// 获取产品列表的回调
-(void)finishPay:(id)transactionData
{
    SKPaymentTransaction *transaction = (SKPaymentTransaction*)transactionData;
    NSData *receipt = nil;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        receipt = transaction.transactionReceipt;
    } else {
        // Load resources for iOS 7 or later
        //苹果推荐
        receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    }
    NSString *receiptStr = [receipt base64EncodedStringWithOptions:0];
    if (_localVerify){
        NSLog(@"SKPaymentTransaction：%@",transaction);
        [self verifyReceipt:receiptStr];
    }else{
        NSString *ret = [NSString stringWithFormat:@"%@|%@|%@",
                         transaction.transactionIdentifier,
                         transaction.payment.productIdentifier,
                         receiptStr];
        IAPMsgHandler::getInstance()->handlerData(IAPPAY_SUCCESS,[ret UTF8String]);
    }
}
// 客户端验证收据
-(void) verifyReceipt:(NSString*)receiptStr
{
    // Create the JSON object that describes the request
    NSError *error;
    NSDictionary *requestContents = @{
                                      @"receipt-data": receiptStr
                                      };
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
    if (!requestData) { /* ... Handle error ... */ }
    
    // Create a POST request with the receipt data.
    NSString *url = nil;
    if (_debugMode){
        url = [NSString stringWithUTF8String:IAP_SANDBOX];
    }else{
        url = [NSString stringWithUTF8String:IAP_RELEASE];
    }
    NSURL *storeURL = [NSURL URLWithString:url];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    // Make a connection to the iTunes Store on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
                            {
                               if (connectionError) {
                                   /* ... Handle error ... */
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) { /* ... Handle error ...*/ }
                                   /* ... Send a response back to the device ... */
                                   NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   IAPMsgHandler::getInstance()->handlerData( VERIFY_RECEIPT_RESULT , [str UTF8String]);
                               }
                           }];
}



-(void)dispose{
    [purchase_oc dispose];
    purchase_oc = nil;
}
@end

