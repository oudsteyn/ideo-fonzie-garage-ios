//
//  ItemsTableViewCell.h
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/25/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *part;
@property (weak, nonatomic) IBOutlet UILabel *cost;

@end
