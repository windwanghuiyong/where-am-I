//
//  Place.h
//  WhereAmI
//
//  Created by wanghuiyong on 01/02/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Place : NSObject <MKAnnotation>	// 模型类, 用于标示地图上的点

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end
