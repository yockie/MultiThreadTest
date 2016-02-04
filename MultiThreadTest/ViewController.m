//
//  ViewController.m
//  MultiThreadTest
//
//  Created by baidu on 15/12/11.
//  Copyright © 2015年 yockie. All rights reserved.
//

#import "ViewController.h"
#import "Case1ViewController.h"
#import "Case2ViewController.h"
#import "Case3ViewController.h"
#import "Case4ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self createButtonIndex:1 text:@"NSThread test" action:@selector(btn1Clicked:)];
    [self createButtonIndex:2 text:@"NSInvocationOperation" action:@selector(btn2Clicked:)];
    [self createButtonIndex:3 text:@"NSBlockOperation" action:@selector(btn3Clicked:)];
    [self createButtonIndex:4 text:@"GCD" action:@selector(btn4Clicked:)];
    
}

-(void)createButtonIndex:(NSInteger)index text:(NSString *)text action:(SEL)action {
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 20+40*(index-1), 200, 30)];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)btn1Clicked:(id)sender {
    Case1ViewController * viewController = [[Case1ViewController alloc]init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)btn2Clicked:(id)sender {
    Case2ViewController * viewController = [[Case2ViewController alloc]init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)btn3Clicked:(id)sender {
    Case3ViewController * viewController = [[Case3ViewController alloc]init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)btn4Clicked:(id)sender {
    Case4ViewController * viewController = [[Case4ViewController alloc]init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
