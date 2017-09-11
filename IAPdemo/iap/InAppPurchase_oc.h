//
//  InAppPurchaseManager.h
//  RoN
//
//  Created by CoA Studio on 13-3-18.
//
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

//接口声明
@protocol IAPProtocol <NSObject>
@required
-(void)errorCall:(int)code andErrorMsg:(NSString*_Nullable)error;
-(void)productListCall:(int)code andParams:(NSString*)params; // 获取产品列表的回调
-(void)finishPay:(id)transaction;
@end

@interface InAppPurchase_oc : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    BOOL m_isJailBroken;
    NSString* productId;
}

@property(nonatomic, assign,nullable)  id<IAPProtocol> delegate;

-(void) initIAP;

-(void)RequestProductData:(NSString*_Nullable)pid;
-(bool)CanMakePay;

-(void)buy:(NSString*_Nullable) product; //传Product Id
-(void)getCanBuyProductList:(NSArray *)productIds;

- (void)paymentQueue:(SKPaymentQueue *_Nullable ) queue updatedTransactions:(NSArray*_Nullable) transactions;
-(void) PurchasedTransaction: (SKPaymentTransaction*_Nullable) transaction;
- (void) completeTransaction: (SKPaymentTransaction*_Nullable) transaction;
- (void) failedTransaction: (SKPaymentTransaction *_Nullable)transaction;
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *_Nullable)transaction;
-(void) paymentQueue:(SKPaymentQueue *_Nullable) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *_Nullable)error;
- (void) restoreTransaction: (SKPaymentTransaction *_Nullable)transaction;

-(void)provideContent:(NSString *_Nullable)product;
-(void)recordTransaction:(NSString *_Nullable)product;

-(void) dispose;
@end
