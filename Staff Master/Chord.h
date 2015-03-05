//
//  Chord.h
//  Staff Master
//
//  Created by Taylor Moss on 2/28/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Chord : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * octave;
@property (nonatomic, retain) NSNumber * inversion;
@property (nonatomic, retain) NSNumber * staff;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Chord (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
