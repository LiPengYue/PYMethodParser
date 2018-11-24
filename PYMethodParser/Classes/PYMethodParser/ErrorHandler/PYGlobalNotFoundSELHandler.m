//
//  PYGlobalNotFoundSELHandler.m
//  PYKit_Example
//
//  Created by 李鹏跃 on 2018/11/22.
//  Copyright © 2018年 LiPengYue. All rights reserved.
//

#import "PYGlobalNotFoundSELHandler.h"
#import "PYMethodParserConfig.h"

#ifdef DEBUG
# define py_DLog(...) NSLog(__VA_ARGS__);
#else
# define py_DLog(...);
#endif

@implementation PYGlobalNotFoundSELHandler
+ (void) py_globalNotFoundSEL: (SEL) sel withClass: (Class) clas and_vaList: (va_list)list {
   
}
@end
