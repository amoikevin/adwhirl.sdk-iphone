/*

 RootViewController.m
 
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
 
*/

#import "RootViewController.h"
#import "SimpleViewController.h"
#import "TableController.h"
#import "AdWhirlView.h"
#import "SampleConstants.h"


@implementation RootViewController

/*
- (void)viewDidLoad {
  [super viewDidLoad];

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    if ([UITableViewCell instancesRespondToSelector:@selector(initWithStyle:reuseIdentifier:)]) {
      // iPhone SDK 3.0
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else {
      // iPhone SDK 2.2.1
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
  }

  switch (indexPath.row) {
    case 0:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Simple View";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Simple View";
      }
      break;
    case 1:
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = @"Table Integration";
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = @"Table Integration";
      }
      break;
    case 2:
    {
      NSString *configText;
      if (configFetched) {
        configText = @"Config Fetched";
      }
      else {
        configText = @"Prefetch Config";
      }
      if ([cell respondsToSelector:@selector(textLabel)]) {
        // iPhone SDK 3.0
        cell.textLabel.text = configText;
      }
      else {
        // iPhone SDK 2.2.1
        cell.text = configText;
      }
      break;
    }
  }
  
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case 0:
    {
      SimpleViewController *simple = [[SimpleViewController alloc] initWithNibName:@"SimpleViewController"
                                                                            bundle:nil];
      [self.navigationController pushViewController:simple animated:YES];
      [simple release];
      break;
    }
    case 1:
    {
      TableController *table = [[TableController alloc] initWithNibName:@"TableController"
                                                                 bundle:nil];
      [self.navigationController pushViewController:table animated:YES];
      [table release];
      break;
    }
    case 2:
      if (configFetched) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
      }
      else {
        [AdWhirlView startPreFetchingConfigurationDataWithDelegate:self];
      }
      break;
  }
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark AdWhirlDelegate methods

- (NSString *)adWhirlApplicationKey {
  return kSampleAppKey;
}

- (NSURL *)adWhirlConfigURL {
  return [NSURL URLWithString:kSampleConfigURL];
}

- (void)adWhirlDidReceiveConfig:(AdWhirlView *)adWhirlView {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  configFetched = YES;
  [self.tableView reloadData];
}

@end

