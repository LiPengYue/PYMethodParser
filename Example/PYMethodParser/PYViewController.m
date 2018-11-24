//
//  PYViewController.m
//  PYMethodParser
//
//  Created by LiPengYue on 11/24/2018.
//  Copyright (c) 2018 LiPengYue. All rights reserved.
//

#import "PYViewController.h"
#import <PYMethodParserHeaders.h>
@interface PYViewController ()

@end

@implementation PYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //调用函数
    [self messageSend];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSError *error;
    NSString *selName = @"setupViewBackgroundLayer:andColor:andBlock:";
    [PYMethodParser callMethodWithTarget:self andSelName: selName andError:&error,nil,UIColor.redColor.CGColor];
}


- (void) messageSend {
    NSError *error;
    void(^block)() = ^{
        NSLog(@"😝---block执行");
    };
    
    double doubleArray[] = {1.1,1,2,3,1};
    
    NSString *selName = @"setupViewBackgroundLayer:andColor:andBlock:andDoubleArray:";
    [PYMethodParser callMethodWithTarget:self  andSelName: selName andError:&error,1,UIColor.redColor.CGColor,block,doubleArray];
}


/// 目标函数
- (void) setupViewBackgroundLayer: (int)value
                         andColor: (CGColorRef)color
                         andBlock: (void(^)())block
                   andDoubleArray: (double *)doubleArray{
    CALayer *layer = [CALayer new];
    layer.borderColor = color;
    layer.borderWidth = 2;
    layer.cornerRadius = 10;
    [self.view.layer addSublayer:layer];
    
    layer.frame = CGRectMake(100, 100, 100, 100);
    if (block) {
        block();
    }
    NSLog(@"😝----%lf",doubleArray[0]);
}

// MARK: 处理 函数未找到的情况
//+ (void) py_notFoundSEL:(SEL)sel and_va_list: (va_list)list {
//    NSLog(@"%@ 来处理调用函数错误问题",self);
//}

@end
