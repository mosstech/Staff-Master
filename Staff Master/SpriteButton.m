//
//  SpriteButton.m
//  Staff Master
//
//  Created by Taylor Moss on 2/16/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import "SpriteButton.h"




@implementation SpriteButton

-(void)setDefaults{
    self.userInteractionEnabled = YES;
    self.xScale = 0.5;
    self.yScale = 0.5;
    self.selected = NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.parent.scene.view];
    
    //Must correct the location because the y-position for touch location is inverted with respect to the node's y-position
    CGPoint correctedLocation = CGPointMake(location.x, self.parent.scene.size.height - location.y);

    if (CGRectContainsPoint(self.frame, correctedLocation)) {
        self.alpha = 0.5;
        self.selected = YES;
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.selected) {
        [self.delegate transition:self.name];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.parent.scene.view];
    //Must correct the location because the y-position for touch location is inverted with respect to the node's y-position
    CGPoint correctedLocation = CGPointMake(location.x, self.parent.scene.size.height - location.y);
    
    if (!CGRectContainsPoint(self.frame, correctedLocation)) {
        self.alpha = 1.0;
        self.selected = NO;
    }
}
@end
