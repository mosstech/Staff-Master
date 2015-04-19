//
//  Menu.h
//  Staff Master
//
//  Created by Taylor Moss on 1/25/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIDevice.h"

@interface GameData : NSObject

@property (nonatomic, assign)int device;
@property(nonatomic, assign)int key;
@property(nonatomic, assign)int staff;
@property(nonatomic, assign)int notes;
@property(nonatomic, assign)int lowRange;
@property(nonatomic, assign)int highRange;
@property(nonatomic, retain)NSArray* midiDevices;
@property(nonatomic, retain)MIDIDevice  *selectedDevice;
@property(nonatomic, assign)int bestScore;
@property(nonatomic, assign)bool isPaused;

+(GameData*) sharedData;
-(void)refreshMidiDevices;
-(void)setSelectedDeviceWithIndex:(int)index;
-(void)setSelectedDeviceToNone;

@end
