//
//  WorkOrder.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/25/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkOrderItem.h"
#import "Vehicle.h"

@interface WorkOrder : NSObject

@property (copy,nonatomic)NSDate* createdAt;
@property (copy,nonatomic)NSNumber* number;
@property (copy,nonatomic)NSNumber* laborCost;
@property (copy,nonatomic)NSDate* scheduledDate;
@property (copy,nonatomic)NSString* status;
@property (copy,nonatomic)NSString* alert;
@property (copy,nonatomic)NSArray<WorkOrderItem *>* items;
@property (retain,nonatomic)Vehicle* vehicle;

@end
