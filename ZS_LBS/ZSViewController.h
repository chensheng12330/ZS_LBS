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
<UITableViewDataSource,UITableViewDelegate,
BMKMapViewDelegate, BMKSearchDelegate>
{
    BMKSearch* _search;
    BMKMapView* _mapView;
    
    NSMutableDictionary *myDicTableData;
    NSArray *keys;
    
    BOOL isGetLoction;
}
@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@property (retain, nonatomic) IBOutlet UIView *myTableHeadView;

- (IBAction)RefreshLoctionLBS:(UIButton *)sender;

-(void) Commit:(UIBarButtonItem*)sender;
@end
