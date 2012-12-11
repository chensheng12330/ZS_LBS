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
    NSMutableDictionary *myDicTableData;
    NSArray *keys;
}
@property (retain, nonatomic) IBOutlet UITableView *myTableView;

-(void) Commit:(UIBarButtonItem*)sender;
@end
