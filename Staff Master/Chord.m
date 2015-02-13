//
//  Chord.m
//  Staff Master
//
//  Created by Taylor Moss on 1/29/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import "Chord.h"

@implementation Chord

-(id)init{
    
    self.name = @"";
    self.variation = 0;
    self.inversion = 0;
    self.staff = 0;
    self.notes = [[NSArray alloc]init];
    
    return self;
}

@end


