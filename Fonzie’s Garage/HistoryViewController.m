//
//  HistoryViewController.m
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/25/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import "HistoryViewController.h"
#import "History.h"

@interface HistoryViewController () {
    UIRefreshControl* refreshControl;
}

@property NSMutableArray<History *> *objects;
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchHistory) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = refreshControl;

    [self fetchHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"histroyCell" forIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd HH:mm"];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];

    
    History *h = self.objects[indexPath.row];
    cell.textLabel.text = h.message;
    cell.detailTextLabel.text = [formatter stringFromDate:h.createdAt];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)fetchHistory {
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"x-api-key": @"SsjA0MdYOGag8xSmLomllZ0wk2zp2s1GrXrBxhWuwt",
                               @"cache-control": @"no-cache" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ideo-autonet-node.run.aws-usw02-pr.ice.predix.io/api/vehicle/event"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    [refreshControl endRefreshing];
                                                    
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        NSMutableDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                                                        
                                                        NSArray *events = [s objectForKey:@"events"];
                                                        
                                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                                                        // Always use this locale when parsing fixed format date strings
                                                        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                                                        [formatter setLocale:posix];
                                                        
                                                        NSMutableArray<History *> *list = [[NSMutableArray alloc] init];
                                                        for( NSDictionary *dict in events ) {
                                                            History *h = [[History alloc] init];
                                                            
                                                            h.createdAt = [formatter dateFromString:[dict objectForKey:@"createdAt"]];
                                                            // h.recordedAt = [formatter dateFromString:[dict objectForKey:@"recordedAt"]];
                                                            
                                                            h.hid = [dict objectForKey:@"id"];
                                                            h.message = [dict objectForKey:@"description"];
                                                            
                                                            [list addObject:h];
                                                        }
                                                     
                                                        self.objects = list;
                                                        [self.tableView reloadData];
                                                    }
                                                }];
    [dataTask resume];
}

@end
