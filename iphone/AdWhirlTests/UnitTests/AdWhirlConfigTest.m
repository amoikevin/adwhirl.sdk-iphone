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
#import "GTMSenTestCase.h"
#import "AdWhirlConfig.h"

@interface AdWhirlConfigTest : GTMTestCase {
}
@end


@implementation AdWhirlConfigTest

-(void) setUp {
}

- (void) tearDown {
}

- (void) testAwIntVal {
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

- (void) testAwFloatVal {
  float out;
  STAssertTrue(awFloatVal(&out, [NSNumber numberWithInt:123]),
               @"awFloatVal with NSNumber with int");
  STAssertEquals(out, (float)123.0,
                 @"awFloatVal should convert NSNumber with int");

  STAssertTrue(awFloatVal(&out, [NSNumber numberWithFloat:788.9]),
               @"awFloatVal with NSNumber with float");
  STAssertEquals(out, (float)788.9,
                 @"awFloatVal should convert NSNumber with float");

  STAssertTrue(awFloatVal(&out, @"567.34"), @"awFloatVal with NSString");
  STAssertEquals(out, (float)567.34, @"awFloatVal should convert NSString");

  STAssertFalse(awFloatVal(&out, [NSValue valueWithPointer:@"dummy"]),
                @"awFloatVal should not able to convert NSValue");
}

- (void) testAwDoubleVal {
  double out;
  STAssertTrue(awDoubleVal(&out, [NSNumber numberWithInt:123]),
               @"awDoubleVal with NSNumber with int");
  STAssertEquals(out, (double)123.0,
                 @"awDoubleVal should convert NSNumber with int");

  STAssertTrue(awDoubleVal(&out, [NSNumber numberWithFloat:2233.231]),
               @"awDoubleVal with NSNumber with float");
  NSLog(@"NUUUM %@ %lf", [NSNumber numberWithFloat:2233.231], out);
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
