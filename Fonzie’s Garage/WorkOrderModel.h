//
//  WorkOrderModel.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/26/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkOrder.h"

@protocol ModelLoadDelegate <NSObject>

@required
-(void) workOrderDidFinishRefresh:(NSMutableArray<WorkOrder *>*)workOrders;

@optional
-(void) workOrderWillRefreshModel:(id)sender;

@end

@interface WorkOrderModel : NSObject

@property (nonatomic, weak) id<ModelLoadDelegate> delegate;


+ (NSMutableArray<WorkOrder *> *)current;

- (void)startWorkOrderRefresh;
- (WorkOrder *)findWorkOrder:(NSNumber *)number;
- (void)updateWorkOrder:(WorkOrder *)workOrder;

@end

