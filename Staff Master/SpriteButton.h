//
//  SpriteButton.h
//  Staff Master
//
//  Created by Taylor Moss on 2/16/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol SpriteButtonDelegate <NSObject>

@required

-(void)transition:(NSString *)name;

@end
@interface SpriteButton : SKSpriteNode

@property (weak, nonatomic) id <SpriteButtonDelegate> delegate;
@property (nonatomic, assign) bool selected;

-(void)setDefaults;


@end
