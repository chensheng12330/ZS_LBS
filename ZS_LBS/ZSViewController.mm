//
//  ZSViewController.m
//  ZS_LBS
//
//  Created by Sherwin.Chen on 12-12-11.
//  Copyright (c) 2012年 Sherwin.Chen. All rights reserved.
//

#import "ZSViewController.h"

@interface ZSViewController ()
-(NSArray*) GetAllCheckStore;
@end

@implementation ZSViewController

- (void)dealloc
{
    [keys release];
    [myDicTableData release];
    [_myTableView release];
    [super dealloc];
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

- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error
{
    int a;
    a=error;
    return;
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
    _search = [[BMKSearch alloc]init];
    _search.delegate = self;
    
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
    
    //[cell setSelected:NO];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self GetAllCheckStore].count>=5){ [tableView deselectRowAtIndexPath:indexPath animated:YES]; return;}
    
    NSArray *cityJRD      = [myDicTableData objectForKey:[keys objectAtIndex:indexPath.section]];
    NSMutableDictionary *dicInfo = [cityJRD objectAtIndex:indexPath.row];
                        
    NSNumber *num = [dicInfo objectForKey:@"select"];
    NSNumber *newNum =  [NSNumber numberWithBool:!num.boolValue];
    
    [dicInfo setObject:newNum forKey:@"select"];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
@end
