//
//  ZSViewController.m
//  ZS_LBS
//
//  Created by Sherwin.Chen on 12-12-11.
//  Copyright (c) 2012年 Sherwin.Chen. All rights reserved.
//

/*
 定位失败，重新定位
 */
#import "ZSViewController.h"
//#import <CLLocation.h>
//#import <CoreLocation/CoreLocation.h>

@interface ZSViewController ()
-(NSArray*) GetAllCheckStore;

-(NSArray*) GetNearPonitOnCenterPoint:(CLLocationCoordinate2D)_center MaxNumber:(unsigned int)num;

@end

@implementation ZSViewController

#define PI 3.1415926
double LantitudeLongitudeDist(double lon1,double lat1,
                              double lon2,double lat2)
{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}

- (void)dealloc
{
    [keys release];
    [myDicTableData release];
    [_myTableView release];
    
    [_mapView release];
    [_search  release];
    [_myTableHeadView release];
    [_myLoctionView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"city4jrd" ofType:@"plist"];
    myDicTableData = [[NSMutableDictionary alloc]initWithContentsOfFile:path];    
    keys = [[myDicTableData allKeys] retain];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(Commit:)];
    self.navigationItem.rightBarButtonItem = btn;
    [btn release];
    
    //map
    _mapView = [[BMKMapView alloc] init];
    _mapView.delegate = self;
    
    
    _search = [[BMKSearch alloc]init];
    
    ///
    
//    double t1 = 123345.2341231;
//    double t2 = 234341.3245234;
//    double t3 = t2-t1;
//    
//    NSString *str = [NSString stringWithFormat:@"%lf",t3];
//    
//    double tt =LantitudeLongitudeDist(113.013,28.1904,113.01328,28.1904);
//    
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){28.1904, 113.01328};
//    
//    NSString *str = [NSString stringWithFormat:@"%lf,%lf",pt.latitude,pt.longitude];
//    
//    NSArray *valArray = [[self GetNearPonitOnCenterPoint:pt MaxNumber:5] retain];
//
//    return;
    ///
    
    self.myTableView.tableHeaderView = self.myTableHeadView;
    
    //start indicator
    UIActivityIndicatorView *actView = (UIActivityIndicatorView *)[self.myTableHeadView viewWithTag:2];
    [actView startAnimating];
    isGetLoction = NO;
    
    //begin LBS
    _mapView.showsUserLocation = YES;
    return;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"LBS"];
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *cityJRD = [myDicTableData objectForKey:[keys objectAtIndex:section]];
    
    return [cityJRD count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [myDicTableData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [keys objectAtIndex:section];
}

/*
 <key>StoreID</key>
 <key>StoreName</key>
 <key>Province</key>
 <key>City</key>
 <key>Address</key>
 <key>longitude</key>
 <key>latitude</key>
 <key>select</key>
 <distance>
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"cell_id";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        
//    }
    UITableViewCell *cell;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"none"] autorelease];
    
    NSArray *cityJRD = [myDicTableData objectForKey:[keys objectAtIndex:indexPath.section]];
    NSDictionary *dicInfo= [cityJRD objectAtIndex:indexPath.row];
    
                        
    // cell title
    cell.textLabel.text       = [dicInfo objectForKey:@"StoreName"];
    NSString *comp =[NSString stringWithFormat:@"%@%@%@",[dicInfo objectForKey:@"Province"],[dicInfo objectForKey:@"City"],[dicInfo objectForKey:@"Address"]];
    
    // cell detail text
    cell.detailTextLabel.text = comp;
    
    //cell sets
    NSNumber *num = [dicInfo objectForKey:@"select"];
    if ([num boolValue]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    // other flag
    if (indexPath.section ==0) {
        NSString *strDistance = [dicInfo objectForKey:@"distance"];
        NSString *disStr = [NSString stringWithFormat:@"%.2lf KM",([strDistance doubleValue]/1000.0)];
        
        UILabel *lab = (UILabel *)[cell viewWithTag:100];
        if (lab == NULL) {
            lab = [[UILabel alloc]initWithFrame:CGRectMake(180, 5, 100, 20)];
            [lab setTextAlignment:NSTextAlignmentRight];
            [lab setBackgroundColor:[UIColor clearColor]];
            [lab setFont:[UIFont systemFontOfSize:14]];
            [lab setText:disStr];
            [lab setTag:100];
            
            [cell addSubview:lab];
            [lab release];
        }
        else
        {
            lab.text = disStr;
        }
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //BOOL bl = cell.accessoryType;
    
    if([self GetAllCheckStore].count>=5 && cell.accessoryType==UITableViewCellAccessoryNone){ [tableView deselectRowAtIndexPath:indexPath animated:YES]; return;}
    
    NSArray *cityJRD      = [myDicTableData objectForKey:[keys objectAtIndex:indexPath.section]];
    NSMutableDictionary *dicInfo = [cityJRD objectAtIndex:indexPath.row];
                        
    NSNumber *num = [dicInfo objectForKey:@"select"];
    NSNumber *newNum =  [NSNumber numberWithBool:!num.boolValue];
    
    [dicInfo setObject:newNum forKey:@"select"];
    
    if (indexPath.section <3) {
        NSArray *ar = [tableView indexPathsForVisibleRows];
        [tableView reloadRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    return;
}

#pragma mark - private
-(NSArray*) GetAllCheckStore
{
    NSMutableArray *returnVal = [[[NSMutableArray alloc] init] autorelease];
    
    //find near store's key
    NSMutableArray *muArrKeys = [[NSMutableArray alloc] initWithArray:[myDicTableData allKeys]];
    [muArrKeys removeObjectAtIndex:0];
    
    //get all store
    NSDictionary *calDictData = [myDicTableData dictionaryWithValuesForKeys:muArrKeys];
    for (NSArray *oneTempAr in [calDictData allValues]) {
        for (NSDictionary *twoTempDic in oneTempAr) {
            if ( ((NSNumber*)[twoTempDic objectForKey:@"select"]).boolValue) {
                [returnVal addObject:twoTempDic];
            }
        }
    }
    [muArrKeys release];
    return returnVal;
}

#pragma mark - baidumap
- (IBAction)RefreshLoctionLBS:(UIButton *)sender {
    if (isGetLoction) {
        nCheckLoctionTime++;
        
        if (nCheckLoctionTime>5) {
            [((UIButton *)[self.myTableHeadView viewWithTag:1]) setTitle:@"请开启定位服务权限" forState:UIControlStateNormal];
        }
        
        [_mapView release];
        _mapView = [[BMKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES; //重新启动
        isGetLoction = NO;
        
        //正在定位您当前位置...
        [((UIButton *)[self.myTableHeadView viewWithTag:1]) setTitle:@"正在定位您当前位置..." forState:UIControlStateNormal];
        [((UIActivityIndicatorView *)[self.myTableHeadView viewWithTag:2]) startAnimating];

    }
    return;
}

-(void)Commit:(UIBarButtonItem*)sender;
{
    NSString *msg =[NSString stringWithFormat:@"选择个数%d",[self GetAllCheckStore].count];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    return;
}

- (void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
{
	if (userLocation != nil) {
		NSLog(@"%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
	}
    
    //stop get location
    mapView.showsUserLocation = NO;

    //
    _search.delegate = self;
    [_search reverseGeocode:userLocation.coordinate];
}

- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"StopLocating");
}

- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
	if (error != nil)
		NSLog(@"locate failed: %@", [error localizedDescription]);
	else {
		NSLog(@"locate failed");
	}
    
    UIButton *btn = (UIButton *)[self.myTableHeadView viewWithTag:1];
    [btn setTitle:@"获取失败,点击重新定位." forState:UIControlStateNormal];
    
    UIActivityIndicatorView *actView = (UIActivityIndicatorView *)[self.myTableHeadView viewWithTag:2];
    [actView stopAnimating];
    
    isGetLoction = YES;
	return;
}

- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error
{
    NSLog(@"%@",result.strAddr);
    //set address
    [((UILabel*)[self.myLoctionView viewWithTag:2]) setText:result.strAddr];
    
    //get near honst   result.geoPt
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){28.1904, 113.01328};
    NSArray *valArray = [[self GetNearPonitOnCenterPoint:pt MaxNumber:5] retain];
    
    //add to tableView
    [myDicTableData setObject:valArray forKey:@"附近家润多店"];
    
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.myTableHeadView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                         [UIView animateWithDuration:1.0
                                               delay: 1.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{  
                                              self.myTableHeadView.alpha = 1.0;
                                              //[self.myTableHeadView removeFromSuperview];
                                              
                                              self.myTableView.tableHeaderView = self.myLoctionView;
                                          }  
                                          completion:nil];  
                     }];
    [UIView commitAnimations];
    
    isGetLoction = YES;
    
    [self.myTableView reloadData];
    [valArray release];
    return;
}

-(NSArray*) GetNearPonitOnCenterPoint:(CLLocationCoordinate2D)_center MaxNumber:(unsigned int)num
{
    //CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:_center.latitude longitude:_center.longitude];
    
    NSMutableArray *sortArray =[[NSMutableArray alloc]init];
    
    for(NSArray *arTemp in [myDicTableData allValues])
    {
        for (NSMutableDictionary *ditTemp in arTemp) {
            NSString *strLatitude = [ditTemp objectForKey:@"latitude"];
            NSString *strlongtude = [ditTemp objectForKey:@"longitude"];
            
            //CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:[strLatitude doubleValue] longitude:[strlongtude doubleValue]];
            
            //cal distance
            //CLLocationDistance distance = [centerLocation distanceFromLocation:originLocation]; //m
            
            double distance = LantitudeLongitudeDist(_center.longitude,_center.latitude,[strlongtude doubleValue],[strLatitude doubleValue]);
            
            // setting
            NSString *strDist = [NSString stringWithFormat:@"%lf",distance];
            [ditTemp setObject:strDist forKey:@"distance"];
            
            // add other sort array
            [sortArray addObject:ditTemp];
            //[originLocation release];
        }
    }
    //[centerLocation release];
    
    //sort
    //[sortArray sortedArrayUsingSelector:@selector(info)];
    NSArray *resultArray = [sortArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *number1 = [obj1 objectForKey:@"distance"];
        NSString *number2 = [obj2 objectForKey:@"distance"];;
        
        NSComparisonResult result = ([number1 doubleValue]>[number2 doubleValue])?1:(([number1 doubleValue]==[number2 doubleValue])?0:-1);
        
        return result == NSOrderedDescending; // 升序
        //return result == NSOrderedAscending;  // 降序
    }];
    
    [sortArray release];
    
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,num)];
    
    NSArray *indexArray = [resultArray objectsAtIndexes:indexSet];
    for (NSMutableDictionary *dicInfo in indexArray) {
        [dicInfo setObject:[NSNumber numberWithBool:YES] forKey:@"select"];
    }
    //return
    return indexArray;
}
- (void)viewDidUnload {
    [self setMyTableHeadView:nil];
    [self setMyLoctionView:nil];
    [super viewDidUnload];
}
@end
