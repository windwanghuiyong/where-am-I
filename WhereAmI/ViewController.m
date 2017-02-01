//
//  ViewController.m
//  WhereAmI
//
//  Created by wanghuiyong on 31/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Place.h"

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;	// 指向 Core Location 实例的指针

@property (strong, nonatomic) CLLocation	 *previousPoint;					// 最近一次位置
@property (assign, nonatomic) CLLocationDistance totalMovementDistance;	// 最近一次位置和当前位置的距离

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *horizontalAccuracyLabel;

@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *verticalAccuracyLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceTraveledLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Core Location 实例: 委托, 精度, 权限
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];	// 设置权限, 只会请求一次, 除非设置改变
}

#pragma mark- Location Manager Delegate Methods

// 权限改变时调用, 可用于开始监听位置更新
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Authorization status changed to %d", status);
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];	// 启动位置管理器
            self.mapView.showsUserLocation = YES;			// 自动绘制当前位置
            NSLog(@"start");
            break;
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [self.locationManager stopUpdatingLocation];		// 停止位置管理器
            self.mapView.showsUserLocation = NO;
            NSLog(@"stop");
            break;
        default:
            break;
    }
}

// 定位出错
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSString *errorType = error.code == kCLErrorDenied ? @"Access Denied" : 
    	[NSString stringWithFormat:@"Error code is %ld", (long)error.code, nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location Manager Error" message:errorType preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 确定当前位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 当前位置
    CLLocation *newLocation = [locations lastObject];
    
    // 地理坐标和水平精度
    NSString *latitudeString = [NSString stringWithFormat:@"%g\u00B0", newLocation.coordinate.latitude];
    self.latitudeLabel.text = latitudeString;
    
    NSString *longitudeString = [NSString stringWithFormat:@"%g\u00B0", newLocation.coordinate.longitude];
    self.longitudeLabel.text = longitudeString;
    
    NSString *horizontalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.horizontalAccuracy];
    self.horizontalAccuracyLabel.text = horizontalAccuracyString;
    
    // 海拔高度和垂直精度
    NSString *altitudeString = [NSString stringWithFormat:@"%gm", newLocation.altitude];
    self.altitudeLabel.text = altitudeString;
    
    NSString *verticalAccuracyString = [NSString stringWithFormat:@"%gm", newLocation.verticalAccuracy];
    self.verticalAccuracyLabel.text = verticalAccuracyString;
    
    
    if (newLocation.horizontalAccuracy < 0 /* || newLocation.verticalAccuracy < 0 */) {
        NSLog(@"invalid accuracy");
        return;
    }
    
    if (newLocation.horizontalAccuracy > 100 || newLocation.verticalAccuracy > 50) {
        // accuracy radius is so large, we don't want to use it
        NSLog(@"too large accuracy radius");
        return;
    }
    
    if (self.previousPoint == nil) {
        // 第一个有效更新
        self.totalMovementDistance = 0;
        // 起始位置大头针
        Place *start = [[Place alloc] init];
        start.coordinate = newLocation.coordinate;
        start.title = @"Start Point";
        start.subtitle = @"This is where we started!";
        [self.mapView addAnnotation:start];
        // 显示范围
        MKCoordinateRegion region;
        region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 100, 100);
        [self.mapView setRegion:region animated:YES];
    } else {
        self.totalMovementDistance += [newLocation distanceFromLocation:self.previousPoint];
    }
    self.previousPoint = newLocation;
    // 距离
    NSString *distanceString = [NSString stringWithFormat:@"%gm", self.totalMovementDistance];
    self.distanceTraveledLabel.text = distanceString;
}

@end
