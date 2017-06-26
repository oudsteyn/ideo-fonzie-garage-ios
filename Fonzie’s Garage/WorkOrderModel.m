//
//  WorkOrderModel.m
//  Fonzie’s Garage
//
//  Created by John Oudsteyn on 6/26/17.
//  Copyright © 2017 Exelon Corporation. All rights reserved.
//

#import "WorkOrderModel.h"
#import "WorkOrder.h"

@implementation WorkOrderModel

static NSMutableArray<WorkOrder *> *orders;
//static NSMutableArray<id> *delegates;

+ (NSMutableArray<WorkOrder *> *)current
{
    return orders;
}

/*
+ (void)addDelegate
{
    if (!delegates) {
        
    }
}
*/

- (WorkOrder *)findWorkOrder:(NSNumber *)number
{
    for (WorkOrder *obj in orders){
        if([obj.number intValue] == [number intValue])
            return obj;
    }
    
    return nil;
}

- (void)updateWorkOrder:(WorkOrder *)workOrder {
    for(int i = 0; i < orders.count; i++) {
        if([orders[i].number intValue] == [workOrder.number intValue]) {
            [orders removeObjectAtIndex:i];
            [orders insertObject:workOrder atIndex:i];
            break;
        }
    }
}

- (void)startWorkOrderRefresh
{
    if( self.delegate && [self.delegate respondsToSelector:@selector(workOrderWillRefreshModel:)] ) {
        [self.delegate workOrderWillRefreshModel:self];
    }
    
    
    NSDictionary *headers = @{ @"content-type": @"application/x-www-form-urlencoded",
                               @"x-api-key": @"SsjA0MdYOGag8xSmLomllZ0wk2zp2s1GrXrBxhWuwt",
                               @"cache-control": @"no-cache" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ideo-autonet-node.run.aws-usw02-pr.ice.predix.io/api/work-order"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    session = [NSURLSession sessionWithConfiguration:configuration];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
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
                                                        
                                                        orders = list;
                                                        
                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(workOrderDidFinishRefresh:)]) {
                                                            [self.delegate workOrderDidFinishRefresh:orders];
                                                        }
                                                        NSLog(@"%@", orders);
                                                    }
                                                }];
    [dataTask resume];
}

@end
