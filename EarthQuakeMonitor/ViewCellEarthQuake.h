//
//  ViewCellEarthQuake.h
//  EarthQuakeMonitor
//
//  Created by Israel on 11/11/15.
//  Copyright © 2015 IsraelGtz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewCellEarthQuake : UITableViewCell
@property (nonatomic,strong) NSDictionary* earthQuakeInfo;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier earthqueakeInfo:(NSDictionary*)info;
-(void)adaptAppearanceToInfo;

@end
