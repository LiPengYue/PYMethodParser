
//  PYGlobalMethodParseErrorHandler.m
//  PYKit_Example
//
//  Created by 李鹏跃 on 2018/11/22.
//  Copyright © 2018年 LiPengYue. All rights reserved.
//

#import "PYGlobalNotFoundSELHandlerPrivate.h"
#import "PYGlobalNotFoundSELHandler.h"
#import "PYMethodParserConfig.h"

#ifdef DEBUG
# define py_DLog(...) NSLog(__VA_ARGS__);
#else
# define py_DLog(...);
#endif


@implementation PYGlobalNotFoundSELHandlerPrivate
+ (void) methodParseErrorWithSel:(SEL) sel andClass: (Class) class and_va_list: (va_list) vaList {
    NSMethodSignature *signature;
    Class PYGlobalNotFoundSELHandlerType = [PYMethodParserConfig get_globalNotFoundSELHandlerType];
        // 没有值那么就发送一条固定消息到对象
    SEL remedySEL = NSSelectorFromString(@"py_notFoundSEL:and_va_list:");
    
        signature = [class methodSignatureForSelector: remedySEL];
        if (signature) {
            // 向对象 发送对象方法 '- (void)py_notFoundSEL:(SEL)sel and_va_list: (va_list)vaList' 发送补救信息，并把原来想发送的消息传递过去
            
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:class];
            [invocation setSelector:remedySEL];
            [invocation setArgument:&sel atIndex:2];
            [invocation setArgument:&vaList atIndex:3];
            [self globalNotFoundSEL:sel withClass:class and_vaList:vaList andHandlerClass:class];
            [invocation invoke];
            
        } else {
            // 向PYGlobalNotFoundSELHandler消息: + (void)py_notFoundSEL:(SEL)sel
            
            SEL globalNotFontSEL = NSSelectorFromString(@"py_globalNotFoundSEL:withClass:and_vaList:");
            if (!PYGlobalNotFoundSELHandlerType) {
                PYGlobalNotFoundSELHandlerType = [PYGlobalNotFoundSELHandler class];
            }
            if([PYGlobalNotFoundSELHandlerType respondsToSelector:globalNotFontSEL]) {
                
                NSMethodSignature *signature =
                [PYGlobalNotFoundSELHandlerType methodSignatureForSelector: globalNotFontSEL];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:PYGlobalNotFoundSELHandlerType];
                [invocation setSelector:globalNotFontSEL];
                [invocation setArgument:&sel atIndex:2];
                [invocation setArgument:&class atIndex:3];
                [invocation setArgument:&vaList atIndex:4];
                [self globalNotFoundSEL:sel withClass:PYGlobalNotFoundSELHandlerType and_vaList:vaList andHandlerClass:PYGlobalNotFoundSELHandlerType];
                [invocation invoke];
            }
        }
        return;
}
                    
+ (void) globalNotFoundSEL: (SEL) sel withClass: (Class) clas and_vaList: (va_list)list andHandlerClass: (Class)handlerClass{
    NSString *classString = NSStringFromClass(clas);
    NSString *selString = NSStringFromSelector(sel);
    
    NSString *handlerClassName = NSStringFromClass(handlerClass);
    NSString *description =
    [NSString stringWithFormat:
     @"\n\
     \n    🌶🌶🌶\
     \n    方法调用出错，已经开始进行默认处理\
     \n    【错误处理类】：%@\
     \n    【错误处理方法】：+ py_globalNotFoundSEL:withClass:and_vaList:\
     \n    【调用类】：《%@》\
     \n    【调用方法为】：《%@》\
     \n    🌶🌶🌶\
     \n  .\n ",
     handlerClassName,
     classString,
     selString
     ];
    if ([PYMethodParserConfig get_isPrintfLogWithMethodParserError]) {
        py_DLog(@"%@",description);
    }
}
                    
@end
