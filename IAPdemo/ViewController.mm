//
//  ViewController.m
//  IAPdemo
//
//  Created by Howe on 09/09/2017.
//  Copyright © 2017 Howe. All rights reserved.
//

#import "ViewController.h"
#include "IAPApi.h"
#include "IAPDefine.h"
#include "IAPMsgHandler.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    auto func = [&](int code,const std::string &msg){
        
    };
    auto bfunc = std::bind(func, std::placeholders::_1,std::placeholders::_2);
    IAPApi * api = [IAPApi Instance];
    IAPMsgHandler::getInstance()->registerCallback( IAPCallback(bfunc) );
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)payClick:(id)sender {
    
    
    
}


@end
