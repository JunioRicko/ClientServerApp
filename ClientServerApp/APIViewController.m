//
//  APIViewController.m
//  ClientServerApp
//
//  Created by supermacho on 10.10.17.
//  Copyright © 2017 student. All rights reserved.
//

#import "APIViewController.h"
#import "ServerManager.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "UIScrollView+BottomRefreshControl.h"
@interface APIViewController ()
@property (nonatomic, strong) NSMutableArray* personsArray;
@end

@implementation APIViewController
static NSInteger personsInRequest = 15;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
    self.personsArray = [NSMutableArray array];
    [self getPersonsFromServer];
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = refreshControl;
    
}

- (void)refresh:(id)sender {
    NSLog(@"Refreshing");
    [self getPersonsFromServer];
    // End Refreshing
    
    
    [(UIRefreshControl *)sender endRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - API

- (void) getPersonsFromServer {
    [[ServerManager sharedManager] getPersonsWithOffset:[self.personsArray count]
                                                  count:personsInRequest
                                              onSuccess:^(NSArray *persons) {
                                                  [self.personsArray addObjectsFromArray:persons];
                                                  
                                                  NSMutableArray* newPath = [NSMutableArray array];
                                                  for (int i = (int)[self.personsArray count] - (int)[persons count]; i < [self.personsArray count]; i++) {
                                                      [newPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                                  }
                                                  
                                                  [self.tableView beginUpdates];
                                                  [self.tableView insertRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationTop];
                                                  [self.tableView endUpdates];
                                              }
                                              inFailure:^(NSError *error, NSInteger statusCode) {
                                                  NSLog(@"ERROR = %@, code = %ld", [error localizedDescription], statusCode);
                                              }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"view.png"]];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.personsArray count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString* identifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.row == [self.personsArray count]) {
        cell.textLabel.text = @"PULL TO LOAD";
        cell.imageView.image = nil;
        
    }else {
        User* person = [self.personsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        NSURLRequest* request = [NSURLRequest requestWithURL:person.imageUrl];
        __weak UITableViewCell* weakCell = cell;
        cell.imageView.image = nil;
        
        [cell.imageView setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                           
                                           weakCell.imageView.image = image;
                                          
                                           
                                           weakCell.backgroundColor = [UIColor clearColor];
                                           weakCell.textLabel.textColor = [UIColor whiteColor];
                                           weakCell.imageView.layer.borderWidth = 1.f;
                                           weakCell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
                                           //weakCell.imageView.frame = CGRectMake(weakCell.imageView.frame.origin.x, weakCell.imageView.frame.origin.y, 100, 100);
                                           CALayer *mask = [CALayer layer];
                                           mask.contents = (id)[[UIImage imageNamed:@"mask.png"] CGImage];
                                           mask.frame = CGRectMake(0, 0, 15, 15);
                                           weakCell.imageView.layer.mask = mask;
                                           weakCell.imageView.layer.masksToBounds = YES;
                                           [weakCell layoutSubviews];
                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                           
                                       }];
    }
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    if (indexPath.row == [self.personsArray count]) {
//        [self getPersonsFromServer];
//    }
}



@end
