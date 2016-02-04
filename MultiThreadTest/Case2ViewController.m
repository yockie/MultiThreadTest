//
//  Case2ViewController.m
//  MultiThreadTest
//
//  Created by baidu on 15/12/14.
//  Copyright © 2015年 yockie. All rights reserved.
//

#import "Case2ViewController.h"
#import "YCImageData.h"

#define ROW_COUNT       5
#define COLUMN_COUNT    3
#define ROW_HEIGHT      100
#define ROW_WIDTH       ROW_HEIGHT
#define CELL_SPACING    10

@interface Case2ViewController ()

@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation Case2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)setupView {
    _imageViewArray = [NSMutableArray array];
    for (int i = 0; i<ROW_COUNT; i++) {
        for (int j = 0; j<COLUMN_COUNT; j++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(j*ROW_WIDTH+j*CELL_SPACING, i*ROW_HEIGHT+i*CELL_SPACING, ROW_WIDTH, ROW_HEIGHT)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.view addSubview:imageView];
            [_imageViewArray addObject:imageView];
        }
    }
    
    
    UIButton * buttonStart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonStart.frame = CGRectMake(50, 300, 220, 25);
    [buttonStart setTitle:@"加载图片" forState:UIControlStateNormal];
    [buttonStart setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [buttonStart addTarget:self action:@selector(loadImageWithMultiThread:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonStart];
    
}

- (void)loadImageWithMultiThread:(id)sender {
    
    //创建操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc]init];
    operationQueue.maxConcurrentOperationCount = 5;//设置最大并发线程数
    
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
        
        //创建一个调用操作，object：调用方法参数
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(loadImage:) object:[NSNumber numberWithInt:i]];
        
        //创建完NSInvocationOperation对象并不会调用，它由一个start方法启动操作，但是注意如果直接调用start方法，则此操作会
        //在主线程中调用，一般不会这么操作，而是添加到NSOperationQueue中
        //[invocationOperation start];
        
        
        //注意添加到操作队列后，队列会开启一个县城执行此操作
        [operationQueue addOperation:invocationOperation];
    }
    
    
    
}


- (void)loadImage:(NSNumber *)index {
    
    NSLog(@"current thread : %@", [NSThread currentThread]);
    
    //[NSThread sleepForTimeInterval:5];
    
    NSInteger i = [index integerValue];
    
    //请求数据
    NSData *data = [self requestData:i];
    
    NSThread *currentThread = [NSThread currentThread];
    if (currentThread.isCancelled) {
        [NSThread exit];
    }
    
    YCImageData *imageData = [[YCImageData alloc]init];
    imageData.index = i;
    imageData.data = data;
    
    //将数据显示到UI控件，注意只能在主线程中更新UI
    //另外performSelectorOnMainThread方法是NSObject的分类方法，每个NSObject对象都有此方法
    //它调用的selector方法是当前调用控件的方法，例如使用UIImageView调用的时候selector就是UIIMageView的方法
    //Object：代表调用方法的参数，不过只能传递一个参数（如果有多个参数请使用对象进行封装）
    //waitUntilDone:是否等等线程任务完成执行
    [self performSelectorOnMainThread:@selector(updateImage:) withObject:imageData waitUntilDone:YES];
}

- (NSData *)requestData:(NSInteger)index {
    
    //    1.设置请求路径
    NSURL *url = [NSURL URLWithString:@"http://img.sc115.com/uploads/png/110125/2011012514020588.png"];
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    
    
    return data;
    
    
}

- (void)updateImage:(YCImageData *)imageData {
    UIImage *image = [UIImage imageWithData:imageData.data];
    
    UIImageView *imageView = [_imageViewArray objectAtIndex:imageData.index];
    
    imageView.image = image;
}

@end
