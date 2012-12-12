//
//  ZSViewController.m
//  ZS_LBS
//
//  Created by Sherwin.Chen on 12-12-11.
//  Copyright (c) 2012年 Sherwin.Chen. All rights reserved.
//

#import "ZSViewController.h"
//#import <CLLocation.h>
#import <CoreLocation/CoreLocation.h>

@interface ZSViewController ()
-(NSArray*) GetAllCheckStore;

-(NSArray*) GetNearPonitOnCenterPoint:(CLLocationCoordinate2D)_center MaxNumber:(unsigned int)num;
-(double) doubleForString:(NSString* )_string;
@end

@implementation ZSViewController

- (void)dealloc
{
    [keys release];
    [myDicTableData release];
    [_myTableView release];
    
    [_mapView release];
    [_search  release];
    [_myTableHeadView release];
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
    static NSString *CellIdentifier = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *cityJRD = [myDicTableData objectForKey:[keys objectAtIndex:indexPath.section]];
    NSDictionary *dicInfo= [cityJRD objectAtIndex:indexPath.row];
    
                        
    
    cell.textLabel.text       = [dicInfo objectForKey:@"StoreName"];
    NSString *comp =[NSString stringWithFormat:@"%@%@%@",[dicInfo objectForKey:@"Province"],[dicInfo objectForKey:@"City"],[dicInfo objectForKey:@"Address"]];
    
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
    
    //indexPath.section ==0
    if (1) {
        NSString *strDistance = [dicInfo objectForKey:@"distance"];
        NSString *disStr = [NSString stringWithFormat:@"%.2lf KM",([strDistance doubleValue]/1000.0)];
        
        UILabel *lab = (UILabel *)[cell viewWithTag:100];
        if (lab == NULL) {
            lab = [[UILabel alloc]initWithFrame:CGRectMake(200, 5, 80, 20)];
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
    //if([self GetAllCheckStore].count>=5){ [tableView deselectRowAtIndexPath:indexPath animated:YES]; return;}
    
    NSArray *cityJRD      = [myDicTableData objectForKey:[keys objectAtIndex:indexPath.section]];
    NSMutableDictionary *dicInfo = [cityJRD objectAtIndex:indexPath.row];
                        
    NSNumber *num = [dicInfo objectForKey:@"select"];
    NSNumber *newNum =  [NSNumber numberWithBool:!num.boolValue];
    
    [dicInfo setObject:newNum forKey:@"select"];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //search
    //NSString *strLongitude = [dicInfo objectForKey:@"longitude"];
    //NSString *strlatitude  = [dicInfo objectForKey:@"latitude"];
    
    //NSN
//    NSDecimalNumber * decimaLongitude = [NSDecimalNumber decimalNumberWithString:strLongitude];
//    NSDecimalNumber * decimaLatitude  = [NSDecimalNumber decimalNumberWithString:strlatitude];
//    
//    NSDecimalNumber * multiplierNumber = [NSDecimalNumber decimalNumberWithString:@"1000000"];
//    
//    NSDecimalNumber *product = [decimaLongitude decimalNumberByMultiplyingBy:multiplierNumber];
//    
//    double tt = [product doubleValue];
//    double t1 = 1000000.0;
//    tt = (double)(tt/t1);
//  CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[strlatitude doubleValue],[strLongitude doubleValue]};
//    [_search reverseGeocode:pt];
    
    return;
}

#pragma mark - private
-(NSArray*) GetAllCheckStore
{
    NSMutableArray *returnVal = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSArray *oneTempAr in [myDicTableData allValues]) {
        for (NSDictionary *twoTempDic in oneTempAr) {
            if ( ((NSNumber*)[twoTempDic objectForKey:@"select"]).boolValue) {
                [returnVal addObject:twoTempDic];
            }
        }
    }
    return returnVal;
}

#pragma mark - baidumap
- (IBAction)RefreshLoctionLBS:(UIButton *)sender {
    if (isGetLoction) {
        _mapView.showsUserLocation = YES; //重新启动
        isGetLoction = NO;
    }
    return;
}

-(void)Commit:(UIBarButtonItem*)sender;
{
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
	pt = (CLLocationCoordinate2D){28.220277777778,112.94888888889};
    
    BOOL flag = [_search reverseGeocode:pt];
	if (!flag) {
		NSLog(@"search failed!");
	}
    
    return;
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
    
    mapView.showsUserLocation = NO;

    _search.delegate = self;
    [_search reverseGeocode:userLocation.coordinate];
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
    
    //get near honst
    NSArray *valArray = [[self GetNearPonitOnCenterPoint:result.geoPt MaxNumber:5] retain];
    
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
                                              self.myTableView.tableHeaderView = nil;
                                          }  
                                          completion:nil];  
                     }];
    isGetLoction = YES;
    
    [self.myTableView reloadData];
    [valArray release];
    return;
}

-(NSArray*) GetNearPonitOnCenterPoint:(CLLocationCoordinate2D)_center MaxNumber:(unsigned int)num
{
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:_center.latitude longitude:_center.longitude];
    
    NSMutableArray *sortArray =[[NSMutableArray alloc]init];
    
    for(NSArray *arTemp in [myDicTableData allValues])
    {
        for (NSMutableDictionary *ditTemp in arTemp) {
            NSString *strLatitude = [ditTemp objectForKey:@"latitude"];
            NSString *strlongtude = [ditTemp objectForKey:@"longtude"];
            
            CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:[strLatitude doubleValue] longitude:[strlongtude doubleValue]];
            
            //cal distance
            CLLocationDistance distance = [centerLocation distanceFromLocation:originLocation]; //m
            
            // setting
            NSString *strDist = [NSString stringWithFormat:@"%lf",distance];
            [ditTemp setObject:strDist forKey:@"distance"];
            
            // add other sort array
            [sortArray addObject:ditTemp];
            [originLocation release];
        }
    }
    [centerLocation release];
    
    //sort
    //[sortArray sortedArrayUsingSelector:@selector(info)];
    NSArray *resultArray = [sortArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *number1 = [obj1 objectForKey:@"distance"];
        NSString *number2 = [obj2 objectForKey:@"distance"];;
        
        NSComparisonResult result = [number1 compare:number2];
        
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
    [super viewDidUnload];
}
@end
