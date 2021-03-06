//
//  MasterViewController.m
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/24/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "WorkOrderModel.h"
#import "WorkOrder.h"
#import "WorkOrderItem.h"
#import "Vehicle.h"

@interface MasterViewController () {
    WorkOrderModel *model;
    UIRefreshControl* refreshControl;
    //NSTimer *refreshTimer;

}

@property NSMutableArray<WorkOrder *> *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    model = [[WorkOrderModel alloc] init];
    model.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchOpenWorkOrders) forControlEvents:UIControlEventValueChanged];

    self.tableView.refreshControl = refreshControl;

    [self fetchOpenWorkOrders];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


/*
- (void)dealloc {
    [refreshTimer invalidate];
    refreshTimer = nil;
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
    //if (!self.objects) {
    //    self.objects = [[NSMutableArray alloc] init];
    //}
    //[self.objects insertObject:[NSDate date] atIndex:0];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WorkOrder *wo = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setWorkOrder:wo];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.objects = [WorkOrderModel current];
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    WorkOrder *wo = self.objects[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
     wo.vehicle.year, wo.vehicle.make, wo.vehicle.model];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"WO: %@    Status: %@", [NSString stringWithFormat:@"%04d", [wo.number intValue]], wo.status];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void) workOrderDidFinishRefresh:(NSMutableArray<WorkOrder *>*)workOrders {
    self.objects = workOrders;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    });
}

- (void)fetchOpenWorkOrders {
    [model startWorkOrderRefresh];
}
/*
- (void)fetchOpenWorkOrders {
    NSDictionary *headers = @{ @"content-type": @"application/x-www-form-urlencoded",
                               @"x-api-key": @"SsjA0MdYOGag8xSmLomllZ0wk2zp2s1GrXrBxhWuwt",
                               @"cache-control": @"no-cache" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ideo-autonet-node.run.aws-usw02-pr.ice.predix.io/api/work-order/open"]
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
                                                        
                                                        NSArray *workOrders = [s objectForKey:@"workOrders"];
                                                        
                                                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                                                        // Always use this locale when parsing fixed format date strings
                                                        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                                                        [formatter setLocale:posix];
                                                        
                                                        NSMutableArray<WorkOrder *> *list = [[NSMutableArray alloc] init];
                                                        for( NSDictionary *dict in workOrders ) {
                                                            WorkOrder* wo = [[WorkOrder alloc] init];
                                                            
                                                            wo.createdAt = [formatter dateFromString:[dict objectForKey:@"createdAt"]];
                                                            wo.scheduledDate = [formatter dateFromString:[dict objectForKey:@"scheduledDate"]];
                                                            
                                                            wo.number = [dict objectForKey:@"id"];
                                                            wo.laborCost = [dict objectForKey:@"laborCost"];
                                                            wo.status = [dict objectForKey:@"status"];
                                                            wo.alert = [dict objectForKey:@"alert"];
                                                            
                                                            NSDictionary *vdict = [dict objectForKey:@"vehicle"];
                                                            Vehicle* v = [[Vehicle alloc] init];
                                                            v.licensePlate = [vdict objectForKey:@"licensePlate"];
                                                            v.make = [vdict objectForKey:@"make"];
                                                            v.model = [vdict objectForKey:@"model"];
                                                            v.odometer = [vdict objectForKey:@"odometer"];
                                                            v.vin = [vdict objectForKey:@"vin"];
                                                            v.year = [vdict objectForKey:@"year"];
                                                            
                                                            NSMutableArray<WorkOrderItem *>* items = [[NSMutableArray<WorkOrderItem *> alloc] init];
                                                            NSArray *itms = [dict objectForKey:@"items"];
                                                            for( NSDictionary *i in itms ) {
                                                                WorkOrderItem *woi = [[WorkOrderItem alloc] init];
                                                                
                                                                woi.quantity = [i objectForKey:@"quantity"];
                                                                woi.cost = [i objectForKey:@"cost"];
                                                                
                                                                NSDictionary *part = [i objectForKey:@"part"];
                                                                woi.partDescription = [part objectForKey:@"description"];
                                                                woi.partManufacture = [part objectForKey:@"manufacture"];
                                                                woi.partNumber = [part objectForKey:@"number"];
                                                                
                                                                [items addObject:woi];
                                                            }
                                                            
                                                            wo.items = items;
                                                            wo.vehicle = v;
                                                            [list addObject:wo];
                                                        }
                                                        
                                                        self.objects = list;
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.tableView reloadData];
                                                        });
                                                        
                                                        /*
                                                        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                                                        target:self
                                                                                                      selector:@selector(fetchOpenWorkOrders)
                                                                                                      userInfo:nil
                                                                                                        repeats:NO];
 
                                                        NSLog(@"%@", workOrders);
                                                    }
                                                }];
    [dataTask resume];
}
*/
@end
