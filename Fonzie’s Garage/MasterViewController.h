//
//  MasterViewController.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/24/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkOrderModel.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController  <ModelLoadDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

