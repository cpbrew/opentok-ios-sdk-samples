//
//  ViewController.h
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    
}
@property (weak, nonatomic) IBOutlet UITextField *pubDimensionsTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *subDimensionsTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *cpuUsageTxtFld;
@property (weak, nonatomic) IBOutlet UITextField *memUsageTxtFld;
@property (weak, nonatomic) IBOutlet UISwitch *vp8SwitchOn;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevel;

- (IBAction)sampleCPUUsage:(id)sender;

@end
