//
//  ViewControllerDetail.h
//  EarthQuakeMonitor
//
//  Created by Israel on 11/11/15.
//  Copyright © 2015 IsraelGtz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewControllerDetail : UIViewController<MKMapViewDelegate>

-(id)initWithInfoOfEarthquake:(NSDictionary*)info;

@end
