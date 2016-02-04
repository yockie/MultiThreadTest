//
//  Case1ViewController.m
//  MultiThreadTest
//
//  Created by baidu on 15/12/11.
//  Copyright © 2015年 yockie. All rights reserved.
//

#import "Case1ViewController.h"
#import "YCImageData.h"

#define ROW_COUNT       5
#define COLUMN_COUNT    3
#define ROW_HEIGHT      100
#define ROW_WIDTH       ROW_HEIGHT
#define CELL_SPACING    10

@interface Case1ViewController ()

@property (nonatomic, strong) NSMutableArray *imageViewArray;

@property (nonatomic, strong) NSMutableArray *threadArray;

@end

@implementation Case1ViewController

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
    
    UIButton * buttonStop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonStop.frame = CGRectMake(50, 330, 220, 25);
    [buttonStop setTitle:@"停止加载" forState:UIControlStateNormal];
    [buttonStop setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [buttonStop addTarget:self action:@selector(stopLoadImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonStop];
    
}

- (void)loadImageWithMultiThread:(id)sender {
    
    _threadArray = [NSMutableArray array];
    
    //方法1：使用对象方法
    //创建一个线程，第一个参数是请求的操作，第二个参数是操作方法的参数
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
        
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loadImage:) object:[NSNumber numberWithInt:i]];
        thread.name = [NSString stringWithFormat:@"mythread_%d", i];
        
        [_threadArray addObject:thread];
        
        [thread start];
    }
    
    
    //方法2：使用类方法
    //[NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
    
}

- (void)stopLoadImage:(id)sender {
    for (int i = 0; i < ROW_COUNT*COLUMN_COUNT; i++ ) {
        NSThread *thread  =  _threadArray[i];
        if (!thread.isFinished) {
            [thread cancel];
            NSLog(@"%@ canceled", thread.name);
        }
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
    
    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f]; //maximal timeout is 30s
//    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if ([data length] > 0 && connectionError == nil) {
//            NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//            NSString *filePath = [documentsDir stringByAppendingPathComponent:@"apple.html"];
//            [data writeToFile:filePath atomically:YES];
//            NSLog(@"Successfully saved the file to %@",filePath);
//            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"HTML = %@",html);
//        }else if ([data length] == 0 && connectionError == nil){
//            NSLog(@"Nothing was downloaded.");
//        }else if (connectionError != nil){
//            NSLog(@"Error happened = %@",connectionError);
//        }
//    }];
    
    return data;
    

}

- (void)updateImage:(YCImageData *)imageData {
    UIImage *image = [UIImage imageWithData:imageData.data];
    
    UIImageView *imageView = [_imageViewArray objectAtIndex:imageData.index];
    
    imageView.image = image;
}

@end











































