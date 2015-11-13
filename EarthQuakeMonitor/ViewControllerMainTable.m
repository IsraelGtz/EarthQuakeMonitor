//
//  ViewControllerMainTable.m
//  EarthQuakeMonitor
//
//  Created by Israel on 11/11/15.
//  Copyright © 2015 IsraelGtz. All rights reserved.
//

#import "ViewControllerMainTable.h"
#import "ViewCellEarthQuake.h"
#import "ViewControllerDetail.h"

#define globalQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define urlEarthQuakes [NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"]

@interface ViewControllerMainTable ()
@property (nonatomic,strong) NSMutableArray* _arrayOfIncidents;
@property (nonatomic,strong) NSDictionary* _jsonEarthQuakes;
@property (nonatomic,strong) UIRefreshControl* _refreshControl;
@property (nonatomic,strong) UITableView* _tableView;
@property (nonatomic,strong) MKMapView* _mapView;
@property (nonatomic,strong) UIActivityIndicatorView* _activityIndicator;

@end

@implementation ViewControllerMainTable
@synthesize _arrayOfIncidents;
@synthesize _jsonEarthQuakes;
@synthesize _refreshControl;
@synthesize _tableView;
@synthesize _mapView;
@synthesize _activityIndicator;

-(id)init{
    self = [super init];
    if(self){
    }
    return self;
}

-(void)loadView{
    self.title = @"Earthquake Monitor";
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self._tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 2.0) style:UITableViewStylePlain];
    self._tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self._tableView.delegate = self;
    self._tableView.dataSource = self;
    
    self._refreshControl = [[UIRefreshControl alloc] init];
    [self._refreshControl addTarget:self action:@selector(loadJSONAgain) forControlEvents:UIControlEventValueChanged];
    
    self._activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self._activityIndicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width / 2.0) - (self._activityIndicator.frame.size.width/2.0), ([UIScreen mainScreen].bounds.size.height * 0.75) - (self._activityIndicator.frame.size.height / 2.0), self._activityIndicator.frame.size.width, self._activityIndicator.frame.size.height);
    
    [self._activityIndicator startAnimating];
    
    [self.view addSubview:self._tableView];
    [self._tableView addSubview:self._refreshControl];
    [self.view addSubview:self._activityIndicator];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadJSON];
}

-(void)loadJSONAgain{
    [self._arrayOfIncidents removeAllObjects];
    [self loadJSON];
}

-(void)loadJSON{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                              dataTaskWithURL:urlEarthQuakes completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                  if (data){
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self getJSON:data];
                                                      });
                                                  }else{
                                                      if(error){
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self getJSONFromDisk];
                                                          });
                                                      }
                                                  }
                                              }];
        [downloadTask resume];
    });
}

-(void)getJSON:(NSData*)dataJSON{
    NSError* error;
    self._jsonEarthQuakes = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:&error];
    if(!self._jsonEarthQuakes){
        NSLog(@"Can't format JSON");
    }else{
        [self saveInDisk];
        [self getAllIncidents];
    }
}

-(void)saveInDisk{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"EarthquakeMonitor.json"];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:filePath];
    NSOutputStream* os = [[NSOutputStream alloc] initWithURL:url append:NO];
    [os open];
    [NSJSONSerialization writeJSONObject:self._jsonEarthQuakes toStream:os options:0 error:nil];
    [os close];
    

}

-(void)getJSONFromDisk{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"EarthquakeMonitor.json"];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:filePath];

    NSInputStream *is = [[NSInputStream alloc] initWithURL:url];
    [is open];
    self._jsonEarthQuakes = [NSJSONSerialization JSONObjectWithStream:is options:0 error:nil];
    [is close];
    [self getAllIncidents];
}

-(void)getAllIncidents{
    NSArray* features = [self._jsonEarthQuakes objectForKey:@"features"];
    self._arrayOfIncidents = [[NSMutableArray alloc] initWithArray:[features mutableCopy]];
    [self._tableView reloadData];
    [self._refreshControl endRefreshing];
    [self initializeMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self._arrayOfIncidents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* kCellIdentifier = @"cellID";
 
    ViewCellEarthQuake *cell = (ViewCellEarthQuake*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    NSDictionary* incidentInfo;
    if([self._arrayOfIncidents count]>=[indexPath row])
        incidentInfo = [self._arrayOfIncidents objectAtIndex:[indexPath row]];
    if(cell == nil){

        cell = [[ViewCellEarthQuake alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier earthqueakeInfo:incidentInfo];
    }else{
        [cell setEarthQuakeInfo:incidentInfo];
        [cell adaptAppearanceToInfo];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewCellEarthQuake* cell = [tableView cellForRowAtIndexPath:indexPath];
    ViewControllerDetail* detail = [[ViewControllerDetail alloc] initWithInfoOfEarthquake:cell.earthQuakeInfo];
    [self.navigationController pushViewController:detail animated:YES];
}

-(void)initializeMap{
    if(!self._mapView){
        self._mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height / 2.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 2.0)];
        self._mapView.delegate = self;
        self._mapView.alpha = 0.0;
        [self.view addSubview:self._mapView];
    }
    [self._mapView removeAnnotations:self._mapView.annotations];
    
    if(self._arrayOfIncidents){
        for(NSDictionary* incidentInfo in self._arrayOfIncidents){
            NSDictionary* properties = incidentInfo[@"properties"];
            NSNumber* mag = properties[@"mag"];
            NSString* fullPlace = properties[@"place"];
            NSArray* components = [fullPlace componentsSeparatedByString:@"of "];
            NSString* place;
            if([components count]>0){
                place = [components objectAtIndex:1];
            }else{
                place = [components firstObject];
            }
            
            NSDictionary* geometry = incidentInfo[@"geometry"];
            NSArray* coordinates = geometry[@"coordinates"];
            NSNumber* longitude = [coordinates firstObject];
            NSNumber* latitude = [coordinates objectAtIndex:1];
            CLLocationCoordinate2D coord;
            coord.latitude = latitude.doubleValue;
            coord.longitude = longitude.doubleValue;
            
            MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = coord;
            annotation.title = place;
            annotation.subtitle = [NSString stringWithFormat:@"%.02f",[mag doubleValue]];
            
            [self._mapView addAnnotation:annotation];

        }
    }
    
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 15000, 15000);
    
//    [self._mapView setRegion:region];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //create annotation
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!pinView) {
        NSString* subtitle = [annotation subtitle];
        NSNumber* mag = [NSNumber numberWithDouble:[subtitle doubleValue]];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        if(([mag doubleValue] >= 0.0) && ([mag doubleValue] < 1.0)){
            pinView.pinTintColor = [UIColor colorWithRed:0.0 green:255.0/255.0 blue:0.0 alpha:0.3];
        }else if(([mag doubleValue] >= 9.0) && ([mag doubleValue] < 10.0)){
                pinView.pinTintColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0 alpha:0.3];
        }else if(([mag doubleValue] >= 1.0) && ([mag doubleValue] < 9.0)){
                pinView.pinTintColor = [UIColor colorWithRed:245.0/255.0 green:242.0/255.0 blue:0.0 alpha:0.3];
        }
        pinView.animatesDrop = FALSE;
        pinView.canShowCallout = YES;
        
        //details button
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.rightCalloutAccessoryView = rightButton;
        
    } else {
        NSString* subtitle = [annotation subtitle];
        NSNumber* mag = [NSNumber numberWithDouble:[subtitle doubleValue]];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        if(([mag doubleValue] >= 0.0) && ([mag doubleValue] < 1.0)){
            pinView.pinTintColor = [UIColor colorWithRed:0.0 green:255.0/255.0 blue:0.0 alpha:0.3];
        }else if(([mag doubleValue] >= 9.0) && ([mag doubleValue] < 10.0)){
            pinView.pinTintColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0 alpha:0.3];
        }else if(([mag doubleValue] >= 1.0) && ([mag doubleValue] < 9.0)){
            pinView.pinTintColor = [UIColor colorWithRed:245.0/255.0 green:242.0/255.0 blue:0.0 alpha:0.3];
        }
        pinView.annotation = annotation;
    }
    return pinView;
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    [self._activityIndicator stopAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        self._mapView.alpha = 1.0;
    }];
}


@end
