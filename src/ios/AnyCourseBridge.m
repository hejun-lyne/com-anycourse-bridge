/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#include <sys/types.h>
#include <sys/sysctl.h>
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import <Cordova/CDV.h>
#import "AnyCourseBridge.h"

@interface AnyCourseBridge () {
    NSMutableArray *_areaArray;
}
@end

@implementation AnyCourseBridge

- (void)pluginInitialize {
    [super pluginInitialize];
    [SMS_SDK getZone:^(enum SMS_ResponseState state, NSArray *array)
     {
         if (1==state)
         {
             NSLog(@"sucessfully get the area code");
             //区号数据
             _areaArray = [NSMutableArray arrayWithArray:array];
         }
         else if (0==state)
         {
             NSLog(@"failed to get the area code");
         }
         
     }];
}

- (void)sendSms:(CDVInvokedUrlCommand *)command
{
    __block CDVPluginResult* pluginResult = nil;
    if ([command.arguments count] != 2) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"请输入正确电话号码"}];
    }
    NSString *code = [command.arguments objectAtIndex:0];
    NSString *phone = [command.arguments objectAtIndex:1];
    if (!pluginResult && !_areaArray) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"无法获取支持区域"}];
    }
    if (!pluginResult) {
        int compareResult = 0;
        for (int i=0; i<_areaArray.count; i++)
        {
            NSDictionary* dict1=[_areaArray objectAtIndex:i];
            NSString* code1=[dict1 valueForKey:@"zone"];
            if ([code1 isEqualToString:code])
            {
                compareResult=1;
                NSString* rule1=[dict1 valueForKey:@"rule"];
                NSPredicate* pred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
                BOOL isMatch=[pred evaluateWithObject:phone];
                if (!isMatch)
                {
                    //手机号码不正确
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"手机号码格式错误"}];
                }
                break;
            }
        }
        
        if (!compareResult)
        {
            if (phone.length!=11)
            {
                //手机号码不正确
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"手机号码格式错误"}];
            }
        }
        
    }
    if (!pluginResult) {
        [SMS_SDK getVerificationCodeBySMSWithPhone:phone
                                              zone:code
                                            result:^(SMS_SDKError *error)
         {
             if (!error)
             {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"message":@"验证码已发送"}];
             }
             else
             {
                 pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"验证码发送失败"}];
             }
             [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
         }];
    } else {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)verify:(CDVInvokedUrlCommand *)command
{
    __block CDVPluginResult* pluginResult = nil;
    NSString *code = [command.arguments objectAtIndex:0];
    if(code.length!=4)
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"验证码输入错误"}];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    else
    {
        //[[SMS_SDK sharedInstance] commitVerifyCode:self.verifyCodeField.text];
        [SMS_SDK commitVerifyCode:code result:^(enum SMS_ResponseState state) {
            if (1==state)
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"message":@"验证成功"}];
            }
            else if(0==state)
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:@{@"message":@"验证失败"}];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

- (void)verifyOnce:(CDVInvokedUrlCommand *)command {
    return;
}

@end
