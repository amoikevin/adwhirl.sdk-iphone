/*

 AdWhirlAdapterMdotM.m
 
 Copyright 2009 AdMob, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 Author: Sourabh Niyogi (MdotM)
 
*/

#import "AdWhirlAdapterMdotM.h"
#import "AdWhirlView.h"
#import "AdWhirlConfig.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlDelegateProtocol.h"
#import "AdWhirlLog.h"
#import "AdWhirlAdNetworkAdapter+Helpers.h"
#import "AdWhirlAdNetworkRegistry.h"


@implementation AdWhirlAdapterMdotM

+ (AdWhirlAdNetworkType)networkType {
  return AdWhirlAdNetworkTypeMdotM;
}

+ (void)load {
  [[AdWhirlAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
  MdotMView *adView = [[MdotMView alloc] initWithDelegate:self];
  if ([adWhirlDelegate respondsToSelector:@selector(MdotMApplicationKey)]) {
    adView.mdotmAppKey = [adWhirlDelegate MdotMApplicationKey];
  }
  else {
 }
	
  adView.delegate = self;
  self.adNetworkView = adView;
  [adView release];
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark MdotMDelegate methods

- (NSString *)MdotMApplicationKey {
	if ([adWhirlDelegate respondsToSelector:@selector(MdotMApplicationKey)]) {
		return [adWhirlDelegate MdotMApplicationKey];
	}
	return networkConfig.pubId;
}

#pragma mark MdotMDelegate notification methods

- (void)didReceiveAd:(MdotMView *)adView
{
	[self helperFitAdNetworkView];
	[adWhirlView adapter:self didReceiveAdView:adNetworkView];
}

- (void)didFailToReceiveAd:(MdotMView *)adView
{
	[adWhirlView adapter:self didFailAd:nil];
}

#pragma mark MdotMDelegate config methods

- (BOOL)mayAskForLocation {
	return adWhirlConfig.locationOn;
}

- (BOOL)useTestAd {
	if ([adWhirlDelegate respondsToSelector:@selector(adWhirlTestMode)])
		return [adWhirlDelegate adWhirlTestMode];
	return NO;
}


#pragma mark MdotMDelegate optional methods

- (BOOL)respondsToSelector:(SEL)selector {
	if (selector == @selector(location)
		&& ![adWhirlDelegate respondsToSelector:@selector(location)]) {
		return NO;
	}
	else if (selector == @selector(MdotMUserContext)
			 && ![adWhirlDelegate respondsToSelector:@selector(MdotMUserContext)]) {
		return NO;
	}
  return [super respondsToSelector:selector];
}


- (CLLocation *)location {
	return [adWhirlDelegate locationInfo];
}

- (NSDictionary *)MdotMUserContext {
	return [adWhirlDelegate MdotMUserContext];
}

@end
