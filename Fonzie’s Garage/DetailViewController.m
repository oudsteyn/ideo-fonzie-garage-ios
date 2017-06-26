//
//  DetailViewController.m
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/24/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import "DetailViewController.h"
#import "ItemsTableViewCell.h"
#import "WorkOrderItem.h"

@interface DetailViewController () {
    WorkOrderModel *model;
}
@end

@implementation DetailViewController

- (void)configureView {
    self.detailDescriptionLabel.text = @"";
    self.workOrderNumber.text = @"";
    self.workOrderStatus.text = @"";
    self.workOrderAlert.text = @"";
    self.vehicleYear.text = @"";
    self.vehicleMake.text = @"";
    self.vehicleModel.text = @"";
    self.vehicleOdometer.text = @"";
    self.vehicleLicensePlate.text = @"";
    self.partsCost.text = [NSString stringWithFormat:@"$%.02f", 0.0];
    self.laborCost.text = [NSString stringWithFormat:@"$%.02f", 0.0];
    self.totalCost.text = [NSString stringWithFormat:@"$%.02f", 0.0];

    // Update the user interface for the detail item.
    if (self.workOrder) {
        self.detailDescriptionLabel.text = self.workOrder.vehicle.vin;
        self.workOrderNumber.text = [NSString stringWithFormat:@"%04d", [self.workOrder.number intValue]];
        self.workOrderStatus.text = self.workOrder.status;
        self.workOrderAlert.text = self.workOrder.alert;
        self.vehicleYear.text = [NSString stringWithFormat:@"%d", [self.workOrder.vehicle.year intValue]];
        self.vehicleMake.text = self.workOrder.vehicle.make;
        self.vehicleModel.text = self.workOrder.vehicle.model;
        self.vehicleOdometer.text = [NSString stringWithFormat:@"%d", [self.workOrder.vehicle.odometer intValue]];
        self.vehicleLicensePlate.text = self.workOrder.vehicle.licensePlate;
        
        float partsCost = 0;
        for( WorkOrderItem *item in self.workOrder.items ) {
            partsCost += [item.quantity floatValue] * [item.cost floatValue];
        }
        
        float laborCost = [self.workOrder.laborCost floatValue];
        
        self.partsCost.text = [NSString stringWithFormat:@"$%.02f", partsCost];
        self.laborCost.text = [NSString stringWithFormat:@"$%.02f", laborCost];
        self.totalCost.text = [NSString stringWithFormat:@"$%.02f", partsCost + laborCost];
    }
    
    [self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    model = [[WorkOrderModel alloc] init];
    model.delegate = self;

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self refreshWorkOrder];
}


- (IBAction)refreshData:(UIButton *)sender {
    [model startWorkOrderRefresh];
}

-(void) workOrderDidFinishRefresh:(NSMutableArray<WorkOrder *>*)workOrders {
    self.workOrder = [model findWorkOrder:self.workOrder.number];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureView];
    });
}

- (void)refreshWorkOrder {
    [model startWorkOrderRefresh];
}


- (IBAction)workingStatus:(UIButton *)sender {
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"x-api-key": @"SsjA0MdYOGag8xSmLomllZ0wk2zp2s1GrXrBxhWuwt",
                               @"cache-control": @"no-cache" };
    
    NSDictionary *parameters = @{ @"workOrder": @{ @"id": self.workOrder.number, @"status": @"Working" } };
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ideo-autonet-node.run.aws-usw02-pr.ice.predix.io/api/work-order"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                        NSLog(@"%@", httpResponse);
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            self.workOrder.status = @"Working";
                                                            [self configureView];
                                                        });
                                                        
                                                        [self refreshWorkOrder];
                                                    }
                                                }];
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setWorkOrder:(WorkOrder *)newWorkOrder {
    if (_workOrder != newWorkOrder) {
        _workOrder = newWorkOrder;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.workOrder && self.workOrder.items) {
        return self.workOrder.items.count;
    }
    
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    
    WorkOrderItem *woi = self.workOrder.items[indexPath.row];
    
    cell.part.text = [NSString stringWithFormat:@"%@ %@ (%@)", woi.partManufacture, woi.partDescription, woi.partNumber];
    cell.quantity.text = [NSString stringWithFormat:@"%@", woi.quantity];
    cell.cost.text = [NSString stringWithFormat:@"$%.02f", [woi.cost floatValue]];
    
    return cell;
}


@end
