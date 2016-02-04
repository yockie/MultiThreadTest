//
//  Case3ViewController.m
//  MultiThreadTest
//
//  Created by baidu on 15/12/14.
//  Copyright © 2015年 yockie. All rights reserved.
//

#import "Case3ViewController.h"

#define ROW_COUNT       5
#define COLUMN_COUNT    3
#define ROW_HEIGHT      100
#define ROW_WIDTH       ROW_HEIGHT
#define CELL_SPACING    10

@interface Case3ViewController ()

@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation Case3ViewController

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
    //operationQueue.maxConcurrentOperationCount = 5; //设置最大并发线程数
    
    NSBlockOperation *preBlockOperation = nil;
    
    //创建多个线程用于填充图片
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
        //方法1：创建操作块添加到队列
        //创建多线程操作
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            [self loadImage:[NSNumber numberWithInt:i ]];
        }];
        //设置依赖操作为前一张图片加载操作
        if (preBlockOperation) {
            [blockOperation addDependency:preBlockOperation];
        }
        
        preBlockOperation = blockOperation;
        
        //创建操作队列
        [operationQueue addOperation:blockOperation];
        
//        //方法2：直接使用操作列添加操作
//        [operationQueue addOperationWithBlock:^{
//            [self loadImage:[NSNumber numberWithInt:i ]];
//        }];
        
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
    
    //更新UI界面，此处调用了主线程队列的方法（mainQueue是UI主线程）
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateImageWithData:data andIndex:i];
    }];
}

- (NSData *)requestData:(NSInteger)index {
    
    //    1.设置请求路径
    NSURL *url = [NSURL URLWithString:@"http://img.sc115.com/uploads/png/110125/2011012514020588.png"];
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
    
    
    return data;
    
    
}

- (void)updateImageWithData:(NSData *)data andIndex:(NSInteger)index {
    UIImage *image = [UIImage imageWithData:data];
    
    UIImageView *imageView = [_imageViewArray objectAtIndex:index];
    
    imageView.image = image;
}

@end
