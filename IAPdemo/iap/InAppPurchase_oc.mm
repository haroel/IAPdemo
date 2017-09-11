//
//  InAppPurchaseManager.m
//  RoN
//
//  Created by CoA Studio on 13-3-18.
//
//
#import "InAppPurchase_oc.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include "IAPDefine.h"

@implementation InAppPurchase_oc

- (BOOL)isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath])
    {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath])
    {
        jailbroken = YES;
    }
    return jailbroken;
}

- (NSDictionary *)objectPropertys:(id)objectBean{
    NSMutableDictionary * objDic=[[NSMutableDictionary alloc]init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([objectBean class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        //取到变量名
        const char* char_f =property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        //取到变量值
        id propertyValue=[objectBean valueForKey:propertyName];
        if(propertyValue){
            [objDic setObject:propertyValue forKey:propertyName];
        }
    }
    free(properties);
    return objDic;
}

-(void)initIAP
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    productId = nil;
    m_isJailBroken = [self isJailbroken];
}

-(void)buy:(NSString *)product
{
    if (m_isJailBroken){
        NSLog(@"当前设备已越狱，继续进行支付操作可能会导致程序异常退出！");
        [self.delegate errorCall:ErrorClientInvalid andErrorMsg:@"ERROR_JAILBROKEN"];
    }
    productId = [NSString stringWithString:product];
    NSLog(@"向App Store申请购买的Product ID:%@",productId);
    if ([self CanMakePay])
    {
        [self RequestProductData:product];
        NSLog(@"允许程序内付费购买");
    }else
    {
        NSLog(@"不允许程序内付费购买");
        [self.delegate errorCall:ErrorPaymentNotAllowed andErrorMsg:@"ErrorPaymentNotAllowed"];
    }
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

-(void)getCanBuyProductList:(NSArray *)productIds
{
    productId = nil;
    NSSet *nsset = [NSSet setWithArray:productIds];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
}

-(void)RequestProductData:(NSString*)pid
{
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *productArray = [[NSArray alloc] initWithObjects:pid, nil];
    NSSet *nsset = [NSSet setWithArray:productArray];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
}
///<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSArray *myProduct = response.products;
    NSLog(@"产品Product ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %lu", (unsigned long)[myProduct count]);
    NSMutableArray *dict = [NSMutableArray array];
    SKProduct *cproduct = nil;
    for(SKProduct *product in myProduct)
    {
        [dict addObject:[self objectPropertys:product]];
//        NSLog(@"product info");
//        NSLog(@"SKProduct 描述信息%@", [product description]);
//        NSLog(@"产品标题 %@" , [product localizedTitle]);
//        NSLog(@"产品描述信息: %@" , [product localizedDescription]);
//        NSLog(@"价格: %@" , [product price]);
//        NSLog(@"Product id: %@" , [product productIdentifier]);
        NSString *pId = [product productIdentifier];
        if (  [productId isEqualToString:pId] ){
            cproduct = product;
        }
    }
    NSError *error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"skproducts info: %@",jsonString);
    if (cproduct){
        SKPayment *payment = [SKPayment paymentWithProduct:cproduct];
        NSLog(@"---------发送购买请求------------");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else if ( productId == nil ){

        [self.delegate productListCall:LIST_AVALIABLE andParams:jsonString];
    }else{
        [self.delegate errorCall:ErrorPaymentInvalid andErrorMsg:@"ErrorPaymentInvalid"];
    }
}

//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------");
    [self.delegate errorCall:ErrorPaymentError andErrorMsg:[error localizedDescription]];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

///<> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                [self.delegate finishPay:transaction];
                [self completeTransaction:transaction];
                productId = nil;
                NSLog(@"-----交易完成 --------");
                NSLog(@"不允许程序内付费购买");
                break;
            }
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
                NSLog(@"ERROR:%@",transaction.error);
                [self.delegate errorCall:ErrorPaymentCancelled andErrorMsg:[transaction.error localizedDescription]];
                productId = nil;

                NSLog(@"-----交易失败 --------");
                break;
            }
            case SKPaymentTransactionStateRestored://已经购买过该商品
            {
                [self restoreTransaction:transaction];
                NSLog(@"-----已经购买过该商品 --------");
                break;
            }
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
            {
                NSLog(@"-----商品添加进列表 --------");
                break;
            }
            default:
                break;
        }
    }
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

//记录交易
-(void)recordTransaction:(NSString *)product
{
    NSLog(@"-----记录交易--------");
}
- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    NSLog(@" 交易恢复处理");
    
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"failedTransaction code %ld",transaction.error.code);
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
#pragma mark connection delegate
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----");
    if (error != nil){
        [self.delegate errorCall:ErrorStoreProductNotAvailable andErrorMsg:[error localizedDescription]];
        NSLog(@"ERROR:%@",error);
    }
}

-(void)dispose
{
    self.delegate = nil;
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}
@end
