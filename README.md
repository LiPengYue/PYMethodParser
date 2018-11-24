# PYMethodParser
组件化开发- invocation 消息发送 工具

# 参考
>1. [va_list 、va_start、 va_arg、 va_end 使用说明](https://www.cnblogs.com/bettercoder/p/3488299.html)
>2. [@encode](https://www.jianshu.com/p/da21f097ba64)
>3. [iOS OC内联函数 inline](https://www.jianshu.com/p/d557b0831c6a)
>4. [一、NSInvocation的基本用法](https://blog.csdn.net/wzc10101415/article/details/80305840)


[去下载demo](https://github.com/LiPengYue/PYMethodParser)
[我的工具库](https://github.com/LiPengYue/PYKit)
**pod导入:  `pod 'PYMethodParser'`**

# 简介
**`PYMethodParser`**其实是对`NSInvocation` 的封装，用于动态调用（类）对象方法的工具。

其有几个值得注意的地方：

>1. 方法调用可以无限传参数
>2. 没有找到调用方法的话，有两次机会补救
·如果调用类中实现了`+ (void) py_notFoundSEL:(SEL)sel and_va_list: (va_list)list`,实现了则调用。
·如果没有实现上述类方法，那么将调用` PYGlobalNotFoundSELHandlerType` 指向的类对象的类方法：`+ (void) py_globalNotFoundSEL: (SEL) sel withClass: (Class) clas and_vaList: (va_list)list`
>3. 支持类型： SEL、id、block、int*、基本数据类型、
>4. 不支持：自定义结构体、char*。

# 关于使用
## 1. 参数配置
这些均要在AppDelegate `didFinishLaunchingWithOptions`方法 中进行配置
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//全局参数配置
    [PYMethodParserConfig setupConfig:^(PYMethodParserGlobleConfig *config) {
       config
        .setup_globalNotFoundSELHandlerType([PYAppDelegate class])
        .setup_isPrintfLogWithMethodParserError(true)
        .setup_isPrintfLogWithMethodPraserCallMethodSuccess(true)
        .setup_isPrintf_methodParser_Boxing_Log(true)
        .setup_methodSignatureCacheDelegate(self)
        .setup_methodSignatureMaxCount(100000);
    }];
    return YES;
}
```

· 关于方法解析错误全局处理的类名
```
/**
 * 对PYInvocation调用函数后，出现的异常情况的处理。
 * @warning 为 PYGlobalNotFoundSELHandler 的子类
 * @warning 重写 方法 + (void) py_globalNotFoundSEL: (SEL) sel withClass: (Class) clas and_vaList: (va_list)list;
 * @warning 如果PYGlobalNotFoundSELHandler == nil,那么默认为PYGlobalNotFoundSELHandler类来处理
 * @warning PYGlobalNotFoundSELHandler 主要是Dbug环境下打印了调用函数的对象，还有SEL
 */
static Class PYGlobalNotFoundSELHandlerType;
```

. 关于方法签名的最大缓存数
```
/**
 * 缓存NSMethodSigture最大存储量 可以在AppDelegate中自定义
 * 存量超过后会调用 py_MethodSignatureCacheDelegate 方法
 */
static long long py_maxCacheCount = 200000;
```
. 关于到达最大缓存数后对 `NSMethodSignature` 销毁的回调`delegate`
```
/**
 * 缓存处理的工具类
 
 在缓存的方法签名超过 py_maxCacheCount 的个数后，会触发这个方法
 */

static id <NSCacheDelegate> py_MethodSignatureCacheDelegate;
```


## 2. PYMethodParser： 消息解析与调用
**`PYMethodParser` 暴露了2个方法，用于消息处理，并返回了`PYInvocation`**

**解析**
```
/**
 /**
 解析一个对象方法

 @param target 对象
 @param error 异常
 @return 解析的数据，内部封装了NSInvocation
 @bug 如果传入的sel参数个数与传入的参数列表个数不同，则会崩溃
 @bug 如果对应的参数为空，那么用nil表示
 */
+ (PYInvocation *) parseMethodWithTarget:(id)target andSelName: (NSString *)selName  andError: (NSError *__autoreleasing*)error,...;

/**
 解析一个类方法

 @param className 类对象名字
 @param error error 异常
 @return 解析的数据，内部封装了NSInvocation
 @bug 如果传入的sel参数个数与传入的参数列表个数不同，则会崩溃
 @bug 如果对应的参数为空，那么用nil表示
 */
+ (PYInvocation *) parseMethodWithClassName: (NSString *)className andSelName: (NSString *)selName andError: (NSError *__autoreleasing*)error,...;
```
## 3. 调用方法
```

/**
/**
 
/**
 调用一个对象方法
 
 * @param target 对象
 * @param error 异常
 * @return 解析的数据，内部封装了NSInvocation
 */
+ (PYInvocation *) callMethodWithTarget:(id)target andSelName: (NSString *)selName  andError: (NSError *__autoreleasing*)error,...;

/**
 调用一个类方法
 
 @param className 类对象名字
 @param error error 异常
 @return 解析的数据，内部封装了NSInvocation
 @bug 如果传入的sel参数个数与传入的参数列表个数不同，则会崩溃
 @bug 传入的参数列表类型必须与方法参数列表类型一一对应，（因为内部的va_list 获取数据是根据指针指向的参数地址➕偏移参数类型大小 来获取参数值的，获取完成后会自动把指针指向下一个参数内存空间起始位）
 @bug 如果对应的参数为空，那么用nil表示
 */
+ (PYInvocation *) callMethodWithClassName: (NSString *)className andSelName: (NSString *)selName  andError: (NSError *__autoreleasing*)error,...;
```

## 3. PYInvocation： 消息发送的执行者
主要是对`NSInvocation` 进行了封装,其内部有个`NSInvocation`对象，并且所有的方法，都会间接的对`NSInvocation`进行修改
```

/**
 创建一个对象，根据传入的NSMethodSignature创建一个NSInvocation

 @param sig 方法签名
 @return 新的对象
 */
+ (PYInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig;

/**
 参数列表
 */
//@property (nonatomic,strong) NSArray *arguments;

/**
 添加void *(CF等底层api需要调用这个函数添加)对象参数

 @param void *对象参数
 @param i 参数index（需要从第2 开始，因为函数内置两个参数： self 与 _cmd）
 */
- (void)setArgumentWith_CFPointer: (void*) cfpointer andIndex: (NSInteger) i;


@property (readonly, retain) NSMethodSignature *methodSignature;

- (void)retainArguments;
@property (readonly) BOOL argumentsRetained;

@property (nullable, assign) id target;
@property SEL selector;

- (void)getReturnValue:(void *)retLoc;
- (void)setReturnValue:(void *)retLoc;


- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx;

/**
 添加oc对象参数
 
 @param obj oc对象参数
 @param i 参数index（需要从第2 开始，因为函数内置两个参数： self 与 _cmd）
 */
- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx;
/// 执行方法
- (void)invoke;
/// target 执行方法
- (void)invokeWithTarget:(id)target;
```

# 示例：
PYViewController中有方法
```
- (void) setupViewBackgroundLayer: (int)value
                         andColor: (CGColorRef)color
                         andBlock: (void(^)())block
                          andChar: (double *)intArray{
    CALayer *layer = [CALayer new];
    layer.borderColor = color;
    layer.borderWidth = 2;
    layer.cornerRadius = 10;
    [self.view.layer addSublayer:layer];
    
    layer.frame = CGRectMake(100, 100, 100, 100);
    if (block) {
        block();
    }
    NSLog(@"😝----%lf",intArray[0]);
}
```
外部的调用
```
#import "PYMethodParserViewController.h"
#import "PYMethodParser.h"
@interface PYMethodParserViewController ()

@end

@implementation PYMethodParserViewController

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
+ (void) py_notFoundSEL:(SEL)sel and_va_list: (va_list)list {
    NSLog(@"%@ 来处理调用函数错误问题",self);
}
@end
```
# 关于调试
这些`log`只会在`Debug`环境下打印,默认为关闭，想要打印，则需要配置

```
需要引入  #import "PYMethodParserHeaders.h"
然后设置
py_isPrintfLogWithMethodParserError = true
py_isPrintfLogWithMethodPraserCallMethodSuccess = true
py_isPrintf_methodParser_Boxing_Log = true` 
```
## 调用成功打印
>1. 其中 `@encode(int) -> i` `@encode(void*) -> ^{CGColor=}` `@encode(void(^)()) -> @?` `@encode(void*) -> ^d`表示的是解析参数的顺序与类型 
 [@encode](https://www.jianshu.com/p/da21f097ba64)

```

2018-11-24 11:07:47.744935+0800 PYKit_Example[16961:8134409] @encode(int) -> i
2018-11-24 11:07:47.745102+0800 PYKit_Example[16961:8134409] @encode(void*) -> ^{CGColor=}
2018-11-24 11:07:47.745354+0800 PYKit_Example[16961:8134409] @encode(void(^)()) -> @?
2018-11-24 11:07:47.745753+0800 PYKit_Example[16961:8134409] @encode(void*) -> ^d
2018-11-24 11:07:47.746357+0800 PYKit_Example[16961:8134409] 😝---block执行
2018-11-24 11:07:47.746492+0800 PYKit_Example[16961:8134409] 😝----1.100000
2018-11-24 11:07:47.746681+0800 PYKit_Example[16961:8134409]  
                
    ✅ PYInvocation调用方法成功                 
    【target:】<PYMethodParserViewController: 0x7f7f0562ea30>                
    【SEL:】setupViewBackgroundLayer:andColor:andBlock:andDoubleArray:
2018-11-24 11:07:47.780749+0800 PYKit_Example[16961:8134409]  
            
    ✅ PYInvocation被销毁             
    【target:】<PYMethodParserViewController: 0x7f7f0562ea30>            
    【SEL:】setupViewBackgroundLayer:andColor:andBlock:andDoubleArray:            
   
```
## 打印解析方法错误打印
可以清晰的看看到哪个类的哪个方法调用、解析失败
```
2018-11-24 18:35:37.819347+0800 PYMethodParser_Example[34334:9498868] 
                
    🌶 方法签名获取失败                
 
2018-11-24 18:35:37.819512+0800 PYMethodParser_Example[34334:9498868] 
         
    🌶🌶🌶🌶         
    ERROR: 方法调用失败：         
    无法生成PYInvocation：         
    对象：【<PYViewController: 0x7fa8d7d1d440>】         
    方法：setupViewBackgroundLayer:andColor:andBlock:         
    🌶🌶🌶🌶
         
 .
2018-11-24 18:35:37.819727+0800 PYMethodParser_Example[34334:9498868] 
     
    🌶🌶🌶     
    方法调用出错，已经开始进行默认处理     
    【错误处理类】：PYGlobalMethodNotFontHandler     
    【错误处理方法】：+ py_globalNotFoundSEL:withClass:and_vaList:     
    【调用类】：《PYGlobalMethodNotFontHandler》     
    【调用方法为】：《setupViewBackgroundLayer:andColor:andBlock:》     
    🌶🌶🌶     
  .
2018-11-24 18:35:37.819849+0800 PYMethodParser_Example[34334:9498868]     【✅PYGlobalMethodNotFontHandler 已经处理了未识别方法】
```

[去下载demo](https://github.com/LiPengYue/PYMethodParser)
[我的工具库](https://github.com/LiPengYue/PYKit)
**pod导入:  `pod 'PYMethodParser'`**
