//
//  ViewController.m
//  OSSImsgeUpload
//
//  Created by cysu on 5/31/16.
//  Copyright © 2016 cysu. All rights reserved.
//

#import "ViewController.h"
#import "OSSImageUploader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImage *image0 = [UIImage imageNamed:@"test0"];
    UIImage *image1 = [UIImage imageNamed:@"test1"];
    
    [OSSImageUploader asyncUploadImages:@[image0, image1] complete:^(NSArray<NSString *> *names, UploadImageState state) {
        NSLog(@"names---%@", names);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
