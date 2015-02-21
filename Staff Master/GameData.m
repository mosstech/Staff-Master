//
//  Menu.m
//  Staff Master
//
//  Created by Taylor Moss on 1/25/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import "GameData.h"
#import "MIDIUtility.h"

@implementation GameData

static GameData* sharedData = nil;
+(GameData*) sharedData{
    
    if (sharedData == nil) {
        sharedData = [[GameData alloc] init];
    }
    return sharedData;
}

-(id) init{
    if (self = [super init]) {
        self.device = 0;
        self.key = 0;
        self.staff = 0;
        self.notes = 0;
        self.lowRange = 0;
        self.highRange = 0;
        self.midiDevices = [self getMidiDevices];
        self.selectedDevice = [self getMidiDevice];
    }
    return self;
}

-(NSArray *)getMidiDevices{
    ItemCount numOfDevices = MIDIGetNumberOfDevices();
    NSMutableArray *midiDevices = [[NSMutableArray alloc]init];
    
    
    
    for (int i = 0; i < numOfDevices; i++) {
        MIDIDeviceRef midiDeviceRef = MIDIGetDevice(i);
        MIDIDevice *midiDevice = [[MIDIDevice alloc]init];
        
        NSDictionary *midiProperties;
        CFPropertyListRef midiPropertiesList = (__bridge CFPropertyListRef)midiProperties;
        
        MIDIObjectGetProperties(midiDeviceRef, &midiPropertiesList, YES);
        
        midiProperties = (__bridge
                          NSDictionary*)midiPropertiesList;

        if ([midiProperties valueForKey:@"offline"] == [NSNumber numberWithInt:0]) {
            if ([[midiProperties valueForKey:@"entities"] count] > 0)
            {
                
                NSDictionary *entities = [[midiProperties valueForKey:@"entities"] objectAtIndex:0];
                
                if ([[entities valueForKey:@"sources"] count] > 0) {
                    
                    NSDictionary *sources = [[entities valueForKey:@"sources"] objectAtIndex:0];
                    midiDevice.midiID = [[sources valueForKey:@"uniqueID"] intValue];
                    midiDevice.name = [entities valueForKey:@"name"];
                    
                    [midiDevices addObject:midiDevice];
                }
            }
        }
        
      
    }
    return midiDevices;
}


-(void)refreshMidiDevices{
    
    self.midiDevices = [self getMidiDevices];
}

-(MIDIDevice *)getMidiDevice{
    
     MIDIDevice *selectedDevice = [[MIDIDevice alloc]init];
    
    if (_midiDevices.count > 0) {
        selectedDevice = _midiDevices[0];
    }
    else{
        selectedDevice.name = @"No MIDI Device";
        selectedDevice.midiID = 0;
    }
    return selectedDevice;
}

-(void)setSelectedDeviceWithIndex:(int)index{
    self.selectedDevice = (MIDIDevice *)self.midiDevices[index];
}

-(void)setSelectedDeviceToNone{
    self.selectedDevice.name = @"No MIDI Device";
    self.selectedDevice.midiID = 0;
}



@end
