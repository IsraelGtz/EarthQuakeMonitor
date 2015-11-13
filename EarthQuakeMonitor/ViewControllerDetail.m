//
//  ViewControllerDetail.m
//  EarthQuakeMonitor
//
//  Created by Israel on 11/11/15.
//  Copyright © 2015 IsraelGtz. All rights reserved.
//

#import "ViewControllerDetail.h"

@interface ViewControllerDetail ()
@property (nonatomic,strong) UIView* _topView;
@property (nonatomic,strong) MKMapView* _mapView;
@property (nonatomic,strong) NSDictionary* _earthquakeInfo;
@property (nonatomic,strong) UIActivityIndicatorView* _activityIndicator;

@end

@implementation ViewControllerDetail
@synthesize _topView;
@synthesize _mapView;
@synthesize _earthquakeInfo;
@synthesize _activityIndicator;

-(id)initWithInfoOfEarthquake:(NSDictionary*)info{
    self = [super init];
    if(self){
        self._earthquakeInfo = info;
    }
    return self;
}

-(void)loadView{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self._topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 60.0, [UIScreen mainScreen].bounds.size.width, ([UIScreen mainScreen].bounds.size.height / 2.0) - 60)];
    [self.view addSubview:self._topView];

    NSDictionary* properties = self._earthquakeInfo[@"properties"];
    NSString* fullPlace = properties[@"place"];
    NSArray* components = [fullPlace componentsSeparatedByString:@"of "];
    NSString* place;
    if([components count]>0){
        place = [components objectAtIndex:1];
    }else{
        place = [components firstObject];
    }
    self.title = place;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createInterface];
}

-(void)createInterface{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    
    self._activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self._activityIndicator.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width / 2.0) - (self._activityIndicator.frame.size.width/2.0), ([UIScreen mainScreen].bounds.size.height * 0.75) - (self._activityIndicator.frame.size.height / 2.0), self._activityIndicator.frame.size.width, self._activityIndicator.frame.size.height);
    
    [self._activityIndicator startAnimating];
    [self.view addSubview:self._activityIndicator];
    
    /////////////////////////////////////////////////////////////// LABELS //////////////////////////////////////////////////////////////////
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineSpacing = 1;
    UIFont* labelFont = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
    UIColor* labelColor = [UIColor colorWithRed:197.0/255.0 green:58.0/255.0 blue:150.0/255.0 alpha:1.0];
    
    NSDictionary* properties = self._earthquakeInfo[@"properties"];
    NSDictionary* geometry = self._earthquakeInfo[@"geometry"];
    NSArray* coordinates = geometry[@"coordinates"];
    
    NSNumber* mag = properties[@"mag"];
    NSNumber* time = properties[@"time"];
    NSDate* dateAndTime = [NSDate dateWithTimeIntervalSince1970:[time longValue]/1000];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:[NSTimeZone localTimeZone].name];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:timeZone];
    NSNumber* longitude = [coordinates firstObject];
    NSNumber* latitude = [coordinates objectAtIndex:1];
    NSNumber* depth = [coordinates objectAtIndex:2];
    
    NSString* magnitudeString = [NSString stringWithFormat:@"Magnitude: %.02f",[mag floatValue]];
    NSString* dateAndTimeString = [NSString stringWithFormat:@"Date and time: %@",[formatter stringFromDate:dateAndTime]];
    NSString* fullPlaceString = [NSString stringWithFormat:@"Place: %@", properties[@"place"]];
    NSString* coordinatesString = [NSString stringWithFormat:@"Longitude: %f \nLatitude: %f \nDepth: %.02f", [longitude floatValue], [latitude floatValue], [depth floatValue]];
    
    UILabel* fullPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 10.0, [UIScreen mainScreen].bounds.size.width - 10.0, 20.0)];
    NSMutableAttributedString *attributedTextLabelFullPlace = [[NSMutableAttributedString alloc] initWithString : fullPlaceString
                                                                                                     attributes : @{NSParagraphStyleAttributeName : paragraphStyle,
                                                                                                                    NSKernAttributeName : @1.0,
                                                                                                                    NSFontAttributeName : labelFont,
                                                                                                                    NSForegroundColorAttributeName : labelColor}];
    fullPlaceLabel.numberOfLines = 2;
    fullPlaceLabel.attributedText = attributedTextLabelFullPlace;
    fullPlaceLabel.lineBreakMode = NSLineBreakByClipping;
    [fullPlaceLabel sizeToFit];
    
    UILabel* magnitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [fullPlaceLabel frame].origin.y + [fullPlaceLabel frame].size.height + 5.0, 20.0, 20.0)];
    NSMutableAttributedString *attributedTextLabelMagnitude = [[NSMutableAttributedString alloc] initWithString : magnitudeString
                                                                                                      attributes : @{NSParagraphStyleAttributeName : paragraphStyle,
                                                                                                                     NSKernAttributeName : @1.0,
                                                                                                                     NSFontAttributeName : labelFont,
                                                                                                                     NSForegroundColorAttributeName : labelColor}];
    magnitudeLabel.numberOfLines = 1;
    magnitudeLabel.attributedText = attributedTextLabelMagnitude;
    magnitudeLabel.lineBreakMode = NSLineBreakByClipping;
    [magnitudeLabel sizeToFit];
    
    
    UILabel* dateAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [magnitudeLabel frame].origin.y + [magnitudeLabel frame].size.height + 5.0, 20.0, 20.0)];
    NSMutableAttributedString *attributedTextLabelDateAndTime = [[NSMutableAttributedString alloc] initWithString : dateAndTimeString
                                                                                                      attributes : @{NSParagraphStyleAttributeName : paragraphStyle,
                                                                                                                     NSKernAttributeName : @1.0,
                                                                                                                     NSFontAttributeName : labelFont,
                                                                                                                     NSForegroundColorAttributeName : labelColor}];
    dateAndTimeLabel.numberOfLines = 1;
    dateAndTimeLabel.attributedText = attributedTextLabelDateAndTime;
    dateAndTimeLabel.lineBreakMode = NSLineBreakByClipping;
    [dateAndTimeLabel sizeToFit];
    
    UILabel* coordinatesLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [dateAndTimeLabel frame].origin.y + [dateAndTimeLabel frame].size.height + 5.0, [UIScreen mainScreen].bounds.size.width - 100.0, 20.0)];
    NSMutableAttributedString *attributedTextLabelCoordinates = [[NSMutableAttributedString alloc] initWithString : coordinatesString
                                                                                                       attributes : @{NSParagraphStyleAttributeName : paragraphStyle,
                                                                                                                      NSKernAttributeName : @1.0,
                                                                                                                      NSFontAttributeName : labelFont,
                                                                                                                      NSForegroundColorAttributeName : labelColor}];
    coordinatesLabel.numberOfLines = 3;
    coordinatesLabel.attributedText = attributedTextLabelCoordinates;
    coordinatesLabel.lineBreakMode = NSLineBreakByClipping;
    [coordinatesLabel sizeToFit];
    
    [self._topView addSubview:magnitudeLabel];
    [self._topView addSubview:dateAndTimeLabel];
    [self._topView addSubview:fullPlaceLabel];
    [self._topView addSubview:coordinatesLabel];
    
    
    [self initializeMap];
}

-(void)initializeMap{
    self._mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height / 2.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 2.0)];
    self._mapView.delegate = self;
    self._mapView.alpha = 0.0;
    
    NSDictionary* properties = self._earthquakeInfo[@"properties"];
    NSNumber* mag = properties[@"mag"];
    NSString* fullPlace = properties[@"place"];
    NSArray* components = [fullPlace componentsSeparatedByString:@"of "];
    NSString* place;
    if([components count]>0){
        place = [components objectAtIndex:1];
    }else{
        place = [components firstObject];
    }
    
    NSDictionary* geometry = self._earthquakeInfo[@"geometry"];
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
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 15000, 15000);
    
    [self._mapView setRegion:region];
    [self._mapView addAnnotation:annotation];
    
    [self.view addSubview:self._mapView];
}

-(void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    [self._activityIndicator stopAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        self._mapView.alpha = 1.0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
