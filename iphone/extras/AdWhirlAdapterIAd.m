/*
 
 AdWhirlAdapterIAd.m
 
 Copyright 2010 AdMob, Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

#import "AdWhirlAdapterIAd.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlView.h"
#import "AdWhirlLog.h"
#import "AdWhirlAdNetworkAdapter+Helpers.h"
#import "AdWhirlAdNetworkRegistry.h"

@implementation AdWhirlAdapterIAd

+ (AdWhirlAdNetworkType)networkType {
	return AdWhirlAdNetworkTypeIAd;
}

+ (void)load {
	if(NSClassFromString(@"ADBannerView") != nil) {
		[[AdWhirlAdNetworkRegistry sharedRegistry] registerClass:self];
	}
}

- (void)getAd {
	ADBannerView *iAdView = [[ADBannerView alloc] init];
	[iAdView setDelegate:self];
	iAdView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
								  
	self.adNetworkView = iAdView;
}

- (void)dealloc {
  ADBannerView *iAdView = (ADBannerView *)self.adNetworkView;
  if (iAdView != nil) {
    iAdView.delegate = nil;
  }
	[super dealloc];
}

#pragma mark IAdDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	[banner sizeToFit];
	[self helperFitAdNetworkView];
	[adWhirlView adapter:self didReceiveAdView:banner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	[adWhirlView adapter:self didFailAd:error];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	[self helperNotifyDelegateOfFullScreenModal];
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	[self helperNotifyDelegateOfFullScreenModalDismissal];
}

@end
