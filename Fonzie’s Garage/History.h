//
//  History.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/25/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject

@property (copy,nonatomic)NSNumber* hid;
@property (copy,nonatomic)NSDate* recordedAt;
@property (copy,nonatomic)NSDate* createdAt;
@property (copy,nonatomic)NSString* message;

@end
