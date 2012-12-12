//
//  main.m
//  ZS_LBS
//
//  Created by Sherwin.Chen on 12-12-11.
//  Copyright (c) 2012年 Sherwin.Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal;
    @autoreleasepool {
        @try {
            retVal= UIApplicationMain(argc, argv, nil, NSStringFromClass([ZSAppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"CRASH: %@", exception);
            NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
            NSLog(@"App Over");
        }
    }
    return retVal;
}

/*
 NSDecimalNumber * decimaLongitude = [NSDecimalNumber decimalNumberWithString:strLongitude];
 NSDecimalNumber * decimaLatitude  = [NSDecimalNumber decimalNumberWithString:strlatitude];
 
 NSDecimalNumber * multiplierNumber = [NSDecimalNumber decimalNumberWithString:@"1000000"];
 
 NSDecimalNumber *product = [decimaLongitude decimalNumberByMultiplyingBy:multiplierNumber];
 
 double tt = [product doubleValue];
 double t1 = 1000000.0;
 tt = (double)(tt/t1);
 CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[strlatitude doubleValue],[strLongitude doubleValue]};
 [_search reverseGeocode:pt];

 */
