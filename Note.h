//
//  Note.h
//  Staff Master
//
//  Created by Taylor Moss on 2/28/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Chord;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * intonation;
@property (nonatomic, retain) NSNumber * octave;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * accidental;
@property (nonatomic, retain) NSNumber * staff;
@property (nonatomic, retain) Chord *chord;

-(int)midiNumber;
-(int)staffLocation;
@end
