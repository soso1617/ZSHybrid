//
//  ZSHybridViewController.m
//  ZSHybrid
//
//  Created by SoSo on 08/31/2016.
//  Copyright (c) 2016 SoSo. All rights reserved.
//

#import "ZSHybridViewController.h"
#import "SampleManagerA.h"

@interface ZSHybridViewController ()

@end

@implementation ZSHybridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //
    //  create scenario manager and load web page
    //
    SampleManagerA *managerA = [SampleManagerA sharedManager];
    [managerA loadScenarioFromViewController:self openMode:SOM_Push completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
