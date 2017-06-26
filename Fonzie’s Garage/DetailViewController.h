//
//  DetailViewController.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/24/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkOrder.h"
#import "WorkOrderModel.h"

@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ModelLoadDelegate>

@property (strong, nonatomic) WorkOrder *workOrder;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *workOrderNumber;
@property (weak, nonatomic) IBOutlet UILabel *workOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *workOrderAlert;
@property (weak, nonatomic) IBOutlet UILabel *vehicleYear;
@property (weak, nonatomic) IBOutlet UILabel *vehicleMake;
@property (weak, nonatomic) IBOutlet UILabel *vehicleModel;
@property (weak, nonatomic) IBOutlet UILabel *vehicleOdometer;
@property (weak, nonatomic) IBOutlet UILabel *vehicleLicensePlate;

@property (weak, nonatomic) IBOutlet UILabel *partsCost;
@property (weak, nonatomic) IBOutlet UILabel *laborCost;
@property (weak, nonatomic) IBOutlet UILabel *totalCost;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

