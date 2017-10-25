#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "IAPApi.h"
#import "IAPDefine.h"
#import "InAppPurchase_oc.h"

FOUNDATION_EXPORT double ez_iapVersionNumber;
FOUNDATION_EXPORT const unsigned char ez_iapVersionString[];

