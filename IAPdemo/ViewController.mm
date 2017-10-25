//
//  ViewController.m
//  IAPdemo
//
//  Created by Howe on 09/09/2017.
//  Copyright © 2017 Howe. All rights reserved.
//

#import "ViewController.h"
#import <ez_iap/IAPDefine.h>
#import <ez_iap/IAPApi.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[IAPApi Instance] setMessageHandler:^(int code, NSString *params) {
        NSLog(@"IAPEvent %d  %@",code,params);
        switch (code) {
            case IAPPAY_SUCCESS:
            {
                break;
            }
            case LIST_AVALIABLE:{
                // 获取产品列表
                break;
            }
            case VERIFY_RECEIPT_RESULT:
            {
                break;
            }
            case ErrorPaymentError:
            case ErrorPaymentNotAllowed:
            case ErrorPaymentInvalid:
            case ErrorStoreProductNotAvailable:
            {
                break;
            }
            case ErrorPaymentCancelled:{
                break;
            }
            default:
            break;
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)payClick:(id)sender {
    
    
    [[IAPApi Instance] buy:@"com.tark.ezgame.rmb1.3" billNo:@"TEST_BILL_NO"];

}


@end
