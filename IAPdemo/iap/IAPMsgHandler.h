//
//  IAPMsgHandler.hpp
//  IAPdemo
//
//  Created by Howe on 09/09/2017.
//  Copyright © 2017 Howe. All rights reserved.
//

#ifndef IAPMsgHandler_hpp
#define IAPMsgHandler_hpp

#include <stdio.h>
#include "IAPDefine.h"

class IAPMsgHandler
{
private:
    IAPMsgHandler();
    virtual ~IAPMsgHandler();
public:
    static IAPMsgHandler* getInstance();
public:
    void registerCallback(const IAPCallback &callback);
    
    void handlerData(int code, const char* msg);
private:
    // 函数声明
    IAPCallback _callBack;
    
};

#endif /* IAPMsgHandler_hpp */
