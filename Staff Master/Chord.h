//
//  Chord.h
//  Staff Master
//
//  Created by Taylor Moss on 1/29/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chord : NSObject


@property (nonatomic, assign)NSString *name;
@property (nonatomic, assign)int variation;
@property (nonatomic, assign)int inversion;
@property (nonatomic, assign)int staff;
@property (strong, nonatomic)NSArray *notes;

-(id)init;

@end
