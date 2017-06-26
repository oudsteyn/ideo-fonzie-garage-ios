//
//  WorkOrderItem.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/25/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkOrderItem : NSObject

@property (copy,nonatomic)NSNumber* quantity;
@property (copy,nonatomic)NSString* partDescription;
@property (copy,nonatomic)NSString* partManufacture;
@property (copy,nonatomic)NSString* partNumber;
@property (copy,nonatomic)NSNumber* cost;

@end
