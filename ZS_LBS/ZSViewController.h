//
//  ZSViewController.h
//  ZS_LBS
//
//  Created by Sherwin.Chen on 12-12-11.
//  Copyright (c) 2012年 Sherwin.Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface ZSViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,
BMKMapViewDelegate, BMKSearchDelegate>
{
    BMKSearch* _search;
    BMKMapView* _mapView;
    
    NSMutableDictionary *myDicTableData;
    NSArray *keys;
    
    BOOL isGetLoction;
    int  nCheckLoctionTime;
    CLLocationCoordinate2D currentLoction;
    CLLocationManager* locationManager;
    
}

@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) IBOutlet UIView *myTableHeadView;
@property (retain, nonatomic) IBOutlet UIView *myLoctionView;

- (IBAction)RefreshLoctionLBS:(UIButton *)sender;

-(void) Commit:(UIBarButtonItem*)sender;
@end
