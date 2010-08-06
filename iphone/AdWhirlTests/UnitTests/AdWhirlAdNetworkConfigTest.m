/*

 AdWhirlAdNetworkConfigTest.m

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

#import <OCMock/OCMock.h>
#import "GTMSenTestCase.h"
#import "AdWhirlAdNetworkConfig.h"
#import "AdWhirlAdNetworkAdapter.h"
#import "AdWhirlError.h"
#import "AdWhirlAdNetworkRegistry.h"
#import "AdWhirlClassWrapper.h"


@interface AdWhirlAdNetworkConfigTest : GTMTestCase {
  id mockRegistry_;
}
@end


@implementation AdWhirlAdNetworkConfigTest

-(void) setUp {
  mockRegistry_ = [OCMockObject mockForClass:[AdWhirlAdNetworkRegistry class]];
}

- (void) tearDown {
}

- (void) testGoodConfig {
  NSDictionary *configDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               @"custom", AWAdNetworkConfigKeyName,
                               @"14.5", AWAdNetworkConfigKeyWeight,
                               @"2798463808b1234567890abcdef5c1e9", AWAdNetworkConfigKeyNID,
                               @"__CUSTOM__", AWAdNetworkConfigKeyCred,
                               @"9", AWAdNetworkConfigKeyType,
                               @"10", AWAdNetworkConfigKeyPriority,
                               nil];
  AdWhirlClassWrapper *classWrapper
    = [[AdWhirlClassWrapper alloc] initWithClass:[AdWhirlAdNetworkAdapter class]];
  [[[mockRegistry_ expect] andReturn:classWrapper] adapterClassFor:9];
  AdWhirlError *error = nil;
  AdWhirlAdNetworkConfig *config
    = [[AdWhirlAdNetworkConfig alloc] initWithDictionary:configDict
                                       adNetworkRegistry:mockRegistry_
                                                   error:&error];
  STAssertNoThrow([mockRegistry_ verify],
                  @"Must have called adapterClassFor of the ad network registry");
  STAssertNil(error, @"should have no error parsing ad network config");
  STAssertNotNil(config, @"config should be non-nil");
  STAssertEqualStrings(config.networkName, @"custom", @"network name");
  STAssertEquals(config.trafficPercentage, 14.5, @"percentage");
  STAssertEqualStrings(config.nid, @"2798463808b1234567890abcdef5c1e9", @"nid");
  STAssertNotNil(config.credentials, @"credentials exists");
  STAssertEqualStrings(config.pubId, @"__CUSTOM__", @"pubId");
  STAssertEquals(config.networkType, 9, @"network type");
  STAssertEquals(config.priority, 10, @"priority");
  STAssertNotNil([config description], @"has description");
  [configDict release];
  [config release];
  [classWrapper release];
}

- (void) testGoodConfigHashCred {
  NSDictionary *cred = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"site_id", @"siteID",
                        @"spot_id", @"spotID",
                        @"pub_id", @"publisherID",
                        nil];
  NSDictionary *configDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"jumptap", AWAdNetworkConfigKeyName,
                              @"30", AWAdNetworkConfigKeyWeight,
                              @"1234567890a1234567890abcdef5c1e9", AWAdNetworkConfigKeyNID,
                              cred, AWAdNetworkConfigKeyCred,
                              @"2", AWAdNetworkConfigKeyType,
                              @"2", AWAdNetworkConfigKeyPriority,
                              nil];
  AdWhirlClassWrapper *classWrapper
    = [[AdWhirlClassWrapper alloc] initWithClass:[AdWhirlAdNetworkAdapter class]];
  [[[mockRegistry_ expect] andReturn:classWrapper] adapterClassFor:2];
  AdWhirlError *error = nil;
  AdWhirlAdNetworkConfig *config
    = [[AdWhirlAdNetworkConfig alloc] initWithDictionary:configDict
                                       adNetworkRegistry:mockRegistry_
                                                   error:&error];
  STAssertNoThrow([mockRegistry_ verify],
                  @"Must have called adapterClassFor of the ad network registry");
  STAssertNil(error, @"should have no error parsing ad network config");
  STAssertNotNil(config, @"config should be non-nil");
  STAssertEqualStrings(config.networkName, @"jumptap", @"network name");
  STAssertEquals(config.trafficPercentage, 30.0, @"percentage");
  STAssertEqualStrings(config.nid, @"1234567890a1234567890abcdef5c1e9", @"nid");
  STAssertNotNil(config.credentials, @"credentials exists");
  STAssertTrue([config.credentials isKindOfClass:[NSDictionary class]],
               @"credentials is a dictionary");
  STAssertNil(config.pubId, @"no single pubId");
  STAssertEqualStrings([config.credentials objectForKey:@"siteID"], @"site_id", @"cred.siteId");
  STAssertEqualStrings([config.credentials objectForKey:@"spotID"], @"spot_id", @"cred.spotId");
  STAssertEqualStrings([config.credentials objectForKey:@"publisherID"], @"pub_id", @"cred.pubId");
  STAssertEquals(config.networkType, 2, @"network type");
  STAssertEquals(config.priority, 2, @"priority");
  STAssertNotNil([config description], @"has description");
  [cred release];
  [configDict release];
  [config release];
  [classWrapper release];
}

- (void) testEmptyConfig {
  NSDictionary *configDict = [NSDictionary dictionaryWithObjectsAndKeys:nil];
  AdWhirlError *error = nil;
  AdWhirlAdNetworkConfig *config
    = [[AdWhirlAdNetworkConfig alloc] initWithDictionary:configDict
                                       adNetworkRegistry:mockRegistry_
                                                   error:&error];
  STAssertNil(config, @"Bad config dict should yield nil network config");
  STAssertNotNil(error, @"Bad config dict should yield error");
  STAssertEquals([error localizedDescription],
                 @"Ad network config has no network type, network id, network name, or priority",
                 @"Bad config dict error message");
  STAssertEquals([error code], AdWhirlConfigDataError, @"Bad config should give AdWhirlConfigDataError");
}

@end
