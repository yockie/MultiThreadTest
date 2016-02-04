//
//  Case4ViewController.m
//  MultiThreadTest
//
//  Created by baidu on 15/12/15.
//  Copyright © 2015年 yockie. All rights reserved.
//

#import "Case4ViewController.h"

#define ROW_COUNT       5
#define COLUMN_COUNT    3
#define ROW_HEIGHT      100
#define ROW_WIDTH       ROW_HEIGHT
#define CELL_SPACING    10

@interface Case4ViewController ()

@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation Case4ViewController

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
    
    //创建一个串行队列，第一个参数：队列名称，第二个参数：队列类型
    
    //DISPATCH_QUEUE_SERIAL:演示串行队列
    //dispatch_queue_t queue = dispatch_queue_create("myThreadQueue1", DISPATCH_QUEUE_SERIAL);//注意queue对象不是指针类型
    
    //演示并行队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //创建多个线程用于填充图片
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
        dispatch_async(queue, ^{
            [self loadImage:[NSNumber numberWithInt:i]];
        });
    }
    
    
    
}


- (void)loadImage:(NSNumber *)index {
    
    NSLog(@"current thread : %@", [NSThread currentThread]);
    
    //[NSThread sleepForTimeInterval:5];
    
    NSInteger i = [index integerValue];
    
    //请求数据
    NSData *data = [self requestData:i];
    
    //更新UI界面，此处调用了GCD主线程队列的方法
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [self updateImageWithData:data andIndex:i];
    });
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
