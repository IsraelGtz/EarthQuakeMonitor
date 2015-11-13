//
//  ViewCellEarthQuake.m
//  EarthQuakeMonitor
//
//  Created by Israel on 11/11/15.
//  Copyright © 2015 IsraelGtz. All rights reserved.
//

#import "ViewCellEarthQuake.h"

@implementation ViewCellEarthQuake
@synthesize earthQuakeInfo;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier earthqueakeInfo:(NSDictionary*)info{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.earthQuakeInfo = info;
        [self adaptAppearanceToInfo];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)adaptAppearanceToInfo{
    if(self.earthQuakeInfo){
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        self.layer.cornerRadius = 3.5;
        self.layer.borderWidth = 2.0;
    
        NSDictionary* properties = self.earthQuakeInfo[@"properties"];
    
    
        NSNumber* mag = properties[@"mag"];
        NSString* fullPlace = properties[@"place"];
        NSArray* components = [fullPlace componentsSeparatedByString:@"of "];
        NSString* place;
        if([components count]>0){
            place = [components objectAtIndex:1];
        }else{
            place = [components firstObject];
        }
        self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
        self.textLabel.textColor = [UIColor blackColor];
        self.textLabel.text = place;
        self.detailTextLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0];
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.text = [NSString stringWithFormat:@"Mag: %.02f",[mag floatValue]];
    
        if(([mag doubleValue] >= 0.0) && ([mag doubleValue] < 1.0)){
            UIView* viewSelectedCell = [[UIView alloc] init];
            UIColor* greenColor = [UIColor colorWithRed:0.0 green:255.0/255.0 blue:0.0 alpha:0.3];
            viewSelectedCell.backgroundColor = greenColor;
            self.selectedBackgroundView = viewSelectedCell;
            self.layer.borderColor = [UIColor greenColor].CGColor;
        }else if(([mag doubleValue] >= 9.0) && ([mag doubleValue] < 10.0)){
            UIView* viewSelectedCell = [[UIView alloc] init];
            UIColor* redColor = [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:0.0 alpha:0.3];
            viewSelectedCell.backgroundColor = redColor;
            self.selectedBackgroundView = viewSelectedCell;
            self.layer.borderColor = [UIColor redColor].CGColor;
        }else if(([mag doubleValue] >= 1.0) && ([mag doubleValue] < 9.0)){
            UIView* viewSelectedCell = [[UIView alloc] init];
            UIColor* yellowColor = [UIColor colorWithRed:245.0/255.0 green:242.0/255.0 blue:0.0 alpha:0.3];
            viewSelectedCell.backgroundColor = yellowColor;
            self.selectedBackgroundView = viewSelectedCell;
            self.layer.borderColor = [UIColor yellowColor].CGColor;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
