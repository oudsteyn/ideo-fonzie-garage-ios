//
//  Vehicle.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/25/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vehicle : NSObject

@property (copy,nonatomic)NSNumber* year;
@property (copy,nonatomic)NSNumber* odometer;
@property (copy,nonatomic)NSString* licensePlate;
@property (copy,nonatomic)NSString* make;
@property (copy,nonatomic)NSString* model;
@property (copy,nonatomic)NSString* vin;

@end
