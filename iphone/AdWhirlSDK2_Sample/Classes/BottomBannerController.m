//
//  BottomBannerController.m
//  AdWhirlSDK2_Sample
//
//  Created by Nigel Choi on 1/26/10.
//  Copyright 2010 Admob. Inc.. All rights reserved.
//

#import "BottomBannerController.h"
#import "AdWhirlView.h"

@implementation BottomBannerController

- (id)init {
  if (self = [super initWithNibName:@"BottomBannerController" bundle:nil]) {
    self.title = @"Bottom Banner";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  CGRect adFrame = [adView frame];
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  adFrame.origin.y = screenBounds.size.height
    - adFrame.size.height
    - self.navigationController.navigationBar.frame.size.height
    - [UIApplication sharedApplication].statusBarFrame.size.height;
  [adView setFrame:adFrame];
}

- (void)dealloc {
    [super dealloc];
}

@end

