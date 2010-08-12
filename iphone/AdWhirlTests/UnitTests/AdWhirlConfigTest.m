/*

 AdWhirlConfigTest.m

 Copyright 2010 Google Inc.

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

#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import "GTMSenTestCase.h"
#import "AdWhirlConfig.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlAdNetworkRegistry.h"
#import "AdWhirlClassWrapper.h"
#import "AdWhirlAdNetworkAdapter.h"
#import "AdWhirlView.h"

@interface AdWhirlConfigTest : GTMTestCase {
}
@end


@interface AdWhirlConfigDelegateCustomURL : NSObject <AdWhirlConfigDelegate> {
}
@end


@implementation AdWhirlConfigDelegateCustomURL

- (NSURL *)adWhirlConfigURL {
  return [NSURL URLWithString:@"http://mob.example.com/getInfo.php"];
}

@end


@interface AdWhirlConfigDelegateNoOp : NSObject <AdWhirlConfigDelegate> {
}
@end


@implementation AdWhirlConfigDelegateNoOp

@end


@implementation AdWhirlConfigTest

-(void)setUp {
}

- (void)tearDown {
}

- (void)testDefaultConfig {
  NSString *appKey = @"myappkey";
  AdWhirlConfigDelegateNoOp *delegate
    = [[AdWhirlConfigDelegateNoOp alloc] init];
  AdWhirlConfig *config = [[AdWhirlConfig alloc] initWithAppKey:appKey
                                                       delegate:delegate];
  STAssertNotNil(config, @"Config should not be nil");

  // Test passed in values
  STAssertEqualStrings(config.appKey, appKey,
                       @"App key should have been set in config");

  // Test default values
  NSURL *actualURL = config.configURL;
  NSURL *defaultURL = [NSURL URLWithString:kAdWhirlDefaultConfigURL];
  STAssertNotNil(actualURL, @"configURL should not be nil");
  STAssertEqualStrings([actualURL scheme], [defaultURL scheme],
                       @"Scheme of config URL should match");
  STAssertEqualStrings([actualURL host], [defaultURL host],
                       @"Host name of config URL should match");
  STAssertEqualStrings([actualURL path], [defaultURL path],
                       @"Path of config URL should match");

  STAssertFalse(config.adsAreOff, @"Ads are on by default");
  STAssertNotNil(config.adNetworkConfigs,
                 @"Config must have ad network config array");
  STAssertEquals([config.adNetworkConfigs count], 0U,
                 @"Config should have no ad network by default");
  STAssertNotNil(config.backgroundColor,
                 @"Config must have background color");
  const CGFloat *bkColComps
    = CGColorGetComponents(config.backgroundColor.CGColor);
  STAssertEquals(bkColComps[0], 0.3F, @"Config default background color red");
  STAssertEquals(bkColComps[1], 0.3F, @"Config default background color green");
  STAssertEquals(bkColComps[2], 0.3F, @"Config default background color blue");
  STAssertEquals(bkColComps[3], 1.0F, @"Config default background color alpha");
  STAssertNotNil(config.textColor, @"Config must have text color");
  STAssertEquals((void *)config.textColor, (void *)[UIColor whiteColor],
                 @"default text color");
  STAssertEquals(config.refreshInterval, (NSTimeInterval)60.0,
                 @"Default refresh interval");
  STAssertTrue(config.locationOn, @"Location query should be on by default");
  STAssertEquals(config.bannerAnimationType, AWBannerAnimationTypeRandom,
                 @"Default banner animation");
  STAssertEquals(config.fullscreenWaitInterval, 60,
                 @"Config default full screen wait interval");
  STAssertEquals(config.fullscreenMaxAds, 2,
                 @"Config default full screen max ads");
  STAssertEquals(config.adNetworkRegistry,
                 [AdWhirlAdNetworkRegistry sharedRegistry],
                 @"Config default ad network registry should be the sharedRegistry");
  STAssertNotNil([config description],
                 @"Config description should not be nil");

  [config release];
  [delegate release];
}

- (void)testLegacyConfig {
  NSString *legacyConfigRaw =
  @"[{"
    @"\"admob_ration\":5,"
    @"\"adrollo_ration\":6,"
    @"\"jumptap_ration\":7,"
    @"\"videoegg_ration\":8,"
    @"\"millennial_ration\":9,"
    @"\"quattro_ration\":11,"
    @"\"generic_ration\":12,"
    @"\"greystripe_ration\":13,"
    @"\"google_adsense_ration\":14,"
    @"\"custom_ration\":15"
  @"},{"
    @"\"admob_key\":\"ADMOB_KEY\","
    @"\"adrollo_key\":\"ADROLLO_KEY\","
    @"\"jumptap_key\":\"JT\","
    @"\"videoegg_key\":{\"publisher\":\"VE_PUB\",\"area\":\"VE_AREA\"},"
    @"\"millennial_key\":\"54321\","
    @"\"quattro_key\":{\"siteID\":\"Q_SITE\",\"publisherID\":\"Q_ID\"},"
    @"\"generic_key\":\"__GENERIC__\","
    @"\"greystripe_key\":\"GREYSTRIPE_KEY\","
    @"\"google_adsense_key\":\"AFMA_KEY\","
    @"\"dontcare_key\":48"
  @"},{"
    @"\"admob_priority\":5,"
    @"\"adwhirl_12_priority\":6,"
    @"\"jumptap_priority\":4,"
    @"\"videoegg_priority\":10,"
    @"\"millennial_priority\":2,"
    @"\"quattro_priority\":1,"
    @"\"generic_priority\":14,"
    @"\"greystripe_priority\":8,"
    @"\"google_adsense_priority\":7,"
    @"\"custom_priority\":13"
  @"},{"
    @"\"background_color_rgb\":{\"red\":7,\"green\":8,\"blue\":9,\"alpha\":1},"
    @"\"text_color_rgb\":{\"red\":200,\"green\":150,\"blue\":100,\"alpha\":1},"
    @"\"refresh_interval\":45,"
    @"\"location_on\":0,"
    @"\"banner_animation_type\":4,"
    @"\"fullscreen_wait_interval\":55,"
    @"\"fullscreen_max_ads\":4,"
    @"\"metrics_url\":\"\","
    @"\"metrics_flag\":0"
  @"}]";

  NSString *appKey = @"myappkey";
  AdWhirlConfigDelegateCustomURL *delegate
    = [[AdWhirlConfigDelegateCustomURL alloc] init];
  AdWhirlConfig *config = [[AdWhirlConfig alloc] initWithAppKey:appKey
                                                       delegate:delegate];
  STAssertNotNil(config, @"Config should not be nil");

  // setup mock registry
  id mockRegistry = [OCMockObject mockForClass:[AdWhirlAdNetworkRegistry class]];
  AdWhirlClassWrapper *classWrapper
    = [[AdWhirlClassWrapper alloc] initWithClass:[AdWhirlAdNetworkAdapter class]];
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:1]; // AdMob
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:2]; // JT
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:3]; // VE
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:6]; // MM
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:7]; // GreyS
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:8]; // Qua
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:9]; // Custom
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:12]; // MdotM
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:14]; // AFMA
  [[[mockRegistry expect] andReturn:classWrapper] adapterClassFor:16]; // G-ric
  config.adNetworkRegistry = mockRegistry;

  // parse this thing
  NSData *configData = [legacyConfigRaw dataUsingEncoding:NSUTF8StringEncoding];
  NSError *error = nil;
  STAssertTrue([config parseConfig:configData error:&error],
               @"Should parse legacy config properly, error: %@", error);
  STAssertNoThrow([mockRegistry verify],
                  @"Must have called adapterClassFor of the ad network registry");

  // check passed-in values
  STAssertEqualStrings(config.appKey, appKey,
                       @"App key should have been set in config");
  NSURL *actualURL = config.configURL;
  NSURL *delegateURL = [delegate adWhirlConfigURL];
  STAssertNotNil(actualURL, @"configURL should not be nil");
  STAssertNotNil(delegateURL, @"delegate should return config URL");
  STAssertEqualStrings([actualURL scheme], [delegateURL scheme],
                       @"Scheme of config URL should match");
  STAssertEqualStrings([actualURL host], [delegateURL host],
                       @"Host name of config URL should match");
  STAssertEqualStrings([actualURL path], [delegateURL path],
                       @"Path of config URL should match");

  // check parsed values
  STAssertFalse(config.adsAreOff, @"Ads should not be off");
  STAssertNotNil(config.adNetworkConfigs,
                 @"Ad net config array should not be nil");
  STAssertEquals([config.adNetworkConfigs count], 10U,
                 @"Right number of ad networks");
  STAssertNotNil(config.backgroundColor,
                 @"Config must have background color");
  const CGFloat *bkColComps
    = CGColorGetComponents(config.backgroundColor.CGColor);
  STAssertEquals(bkColComps[0], (CGFloat)(7.0/255.0),
                 @"Config background color red");
  STAssertEquals(bkColComps[1], (CGFloat)(8.0/255.0),
                 @"Config background color green");
  STAssertEquals(bkColComps[2], (CGFloat)(9.0/255.0),
                 @"Config background color blue");
  STAssertEquals(bkColComps[3], 1.0F, @"Config background color alpha");
  STAssertNotNil(config.textColor, @"Config must have text color");
  const CGFloat *txtColComps
    = CGColorGetComponents(config.textColor.CGColor);
  STAssertEquals(txtColComps[0], (CGFloat)(200.0/255.0), @"Config text color red");
  STAssertEquals(txtColComps[1], (CGFloat)(150.0/255.0), @"Config text color green");
  STAssertEquals(txtColComps[2], (CGFloat)(100.0/255.0), @"Config text color blue");
  STAssertEquals(txtColComps[3], 1.0F, @"Config text color alpha");

  STAssertEquals(config.refreshInterval, (NSTimeInterval)45.0,
                 @"Refresh interval");
  STAssertFalse(config.locationOn, @"Location query setting");
  STAssertEquals(config.bannerAnimationType, AWBannerAnimationTypeCurlDown,
                 @"Banner animation");
  STAssertEquals(config.fullscreenWaitInterval, 55,
                 @"Full screen wait interval");
  STAssertEquals(config.fullscreenMaxAds, 4, @"Full screen max ads");
  STAssertEquals(config.adNetworkRegistry, mockRegistry,
                 @"Ad network registry");

  // check ad network configs
  NSMutableDictionary *seenNetworks
    = [NSMutableDictionary dictionaryWithCapacity:20];
  for (id netCfg in config.adNetworkConfigs) {
    STAssertTrue([netCfg isKindOfClass:[AdWhirlAdNetworkConfig class]],
                 @"netCfg config must be of class AdWhirlAdNetworkConfig");
    AdWhirlAdNetworkConfig *cfg = netCfg;
    STAssertNil([seenNetworks
                 objectForKey:[NSNumber numberWithInt:cfg.networkType]],
                @"Must not have seen network type: %d", cfg.networkType);
    NSString *netTypeString = [NSString stringWithFormat:@"%d",cfg.networkType];
    STAssertEqualStrings(cfg.nid, netTypeString,
                         @"Legacy netCfg nid should be string of network type");
    STAssertEquals(cfg.adapterClass, classWrapper.theClass, @"Adapter class");
    switch (cfg.networkType) {
      case AdWhirlAdNetworkTypeAdMob:
        STAssertEqualStrings(cfg.networkName, @"admob", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)5.0, @"ration");
        STAssertEquals(cfg.priority, 5, @"priority");
        STAssertEqualStrings(cfg.pubId, @"ADMOB_KEY", @"pubId");
        break;
      case AdWhirlAdNetworkTypeJumpTap:
        STAssertEqualStrings(cfg.networkName, @"jumptap", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)7.0, @"ration");
        STAssertEquals(cfg.priority, 4, @"priority");
        STAssertEqualStrings(cfg.pubId, @"JT", @"pubId");
        break;
      case AdWhirlAdNetworkTypeVideoEgg:
        STAssertEqualStrings(cfg.networkName, @"videoegg", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)8.0, @"ration");
        STAssertEquals(cfg.priority, 10, @"priority");
        STAssertEqualStrings([cfg.credentials objectForKey:@"publisher"],
                             @"VE_PUB", @"VideoEgg publisher");
        STAssertEqualStrings([cfg.credentials objectForKey:@"area"],
                             @"VE_AREA", @"VideoEgg area");
        break;
      case AdWhirlAdNetworkTypeMillennial:
        STAssertEqualStrings(cfg.networkName, @"millennial", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)9.0, @"ration");
        STAssertEquals(cfg.priority, 2, @"priority");
        STAssertEqualStrings(cfg.pubId, @"54321", @"pubId");
        break;
      case AdWhirlAdNetworkTypeGreyStripe:
        STAssertEqualStrings(cfg.networkName, @"greystripe", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)13.0, @"ration");
        STAssertEquals(cfg.priority, 8, @"priority");
        STAssertEqualStrings(cfg.pubId, @"GREYSTRIPE_KEY", @"pubId");
        break;
      case AdWhirlAdNetworkTypeQuattro:
        STAssertEqualStrings(cfg.networkName, @"quattro", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)11.0, @"ration");
        STAssertEquals(cfg.priority, 1, @"priority");
        STAssertEqualStrings([cfg.credentials objectForKey:@"siteID"],
                             @"Q_SITE", @"Quattro site id");
        STAssertEqualStrings([cfg.credentials objectForKey:@"publisherID"],
                             @"Q_ID", @"Quattro publisher id");
        break;
      case AdWhirlAdNetworkTypeCustom:
        STAssertEqualStrings(cfg.networkName, @"custom", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)15.0, @"ration");
        STAssertEquals(cfg.priority, 13, @"priority");
        STAssertNil(cfg.pubId, @"Custom ");
        break;
      case AdWhirlAdNetworkTypeMdotM:
        // exercises the adrollo strange logic
        STAssertEqualStrings(cfg.networkName, @"adwhirl_12", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)6.0, @"ration");
        STAssertEquals(cfg.priority, 6, @"priority");
        STAssertEqualStrings(cfg.pubId, @"ADROLLO_KEY", @"pubId");
        break;
      case AdWhirlAdNetworkTypeGoogleAdSense:
        STAssertEqualStrings(cfg.networkName, @"google_adsense",
                             @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)14.0, @"ration");
        STAssertEquals(cfg.priority, 7, @"priority");
        STAssertEqualStrings(cfg.pubId, @"AFMA_KEY", @"pubId");
        break;
      case AdWhirlAdNetworkTypeGeneric:
        STAssertEqualStrings(cfg.networkName, @"generic", @"Network name");
        STAssertEquals(cfg.trafficPercentage, (double)12.0, @"ration");
        STAssertEquals(cfg.priority, 14, @"priority");
        STAssertEqualStrings(cfg.pubId, @"__GENERIC__", @"pubId");
        break;
      default:
        STFail(@"Ad network not in config: %d", cfg.networkType);
        break;
    }
  }

  // clean up
  [config release];
  [delegate release];
  [classWrapper release];
}

- (void)testAddRemoveDelegates {
  NSString *appKey = @"myappkey";
  AdWhirlConfigDelegateNoOp *delegate
    = [[AdWhirlConfigDelegateNoOp alloc] init];
  AdWhirlConfig *config = [[AdWhirlConfig alloc] initWithAppKey:appKey
                                                       delegate:delegate];
  STAssertNotNil(config, @"Config should not be nil");
  STAssertFalse([config addDelegate:delegate],
                @"addDelegate should be false if delegate has been added before");

  AdWhirlConfigDelegateCustomURL *anotherDelegate
    = [[AdWhirlConfigDelegateCustomURL alloc] init];
  STAssertFalse([config removeDelegate:anotherDelegate],
                @"removeDelegate should be false for non-existent delegate");
  STAssertTrue([config addDelegate:anotherDelegate],
               @"addDelegate should be OK when adding another delegate");
  STAssertTrue([config removeDelegate:delegate],
               @"removeDelegate should be OK for existing delegates");

  [delegate release];
  [anotherDelegate release];
  [config release];
}

- (void)testAwIntVal {
  NSInteger out;
  STAssertTrue(awIntVal(&out, [NSNumber numberWithInt:123]),
               @"awIntVal with NSNumber with int");
  STAssertEquals(out, 123, @"awIntVal should convert NSNumber with int");

  STAssertTrue(awIntVal(&out, [NSNumber numberWithFloat:788.9]),
               @"awIntVal with NSNumber with float");
  STAssertEquals(out, 788, @"awIntVal should convert NSNumber with float");

  STAssertTrue(awIntVal(&out, @"567"), @"awIntVal with NSString");
  STAssertEquals(out, 567, @"awIntVal should convert NSString");

  STAssertFalse(awIntVal(&out, [NSValue valueWithPointer:@"dummy"]),
                @"awIntVal should not able to convert NSValue");
}

- (void)testAwFloatVal {
  float out;
  STAssertTrue(awFloatVal(&out, [NSNumber numberWithInt:123]),
               @"awFloatVal with NSNumber with int");
  STAssertEquals(out, 123.0F,
                 @"awFloatVal should convert NSNumber with int");

  STAssertTrue(awFloatVal(&out, [NSNumber numberWithFloat:788.9]),
               @"awFloatVal with NSNumber with float");
  STAssertEquals(out, 788.9F,
                 @"awFloatVal should convert NSNumber with float");

  STAssertTrue(awFloatVal(&out, @"567.34"), @"awFloatVal with NSString");
  STAssertEquals(out, 567.34F, @"awFloatVal should convert NSString");

  STAssertFalse(awFloatVal(&out, [NSValue valueWithPointer:@"dummy"]),
                @"awFloatVal should not able to convert NSValue");
}

- (void)testAwDoubleVal {
  double out;
  STAssertTrue(awDoubleVal(&out, [NSNumber numberWithInt:123]),
               @"awDoubleVal with NSNumber with int");
  STAssertEquals(out, (double)123.0,
                 @"awDoubleVal should convert NSNumber with int");

  STAssertTrue(awDoubleVal(&out, [NSNumber numberWithFloat:2233.231]),
               @"awDoubleVal with NSNumber with float");

  // A bit is lost in the translation from float to double
  STAssertEqualsWithAccuracy(out, (double)2233.231L, 0.001,
                             @"awDoubleVal should convert NSNumber with float");

  STAssertTrue(awDoubleVal(&out, [NSNumber numberWithDouble:788.9]),
               @"awDoubleVal with NSNumber with double");
  STAssertEquals(out, (double)788.9,
                 @"awDoubleVal should convert NSNumber with double");

  STAssertTrue(awDoubleVal(&out, @"567.34"), @"awDoubleVal with NSString");
  STAssertEquals(out, (double)567.34, @"awDoubleVal should convert NSString");

  STAssertFalse(awDoubleVal(&out, [NSValue valueWithPointer:@"dummy"]),
                @"awDoubleVal should not able to convert NSValue");
}

@end
