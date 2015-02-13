//
//  BAudioController.m
//  CoreAudio Starter Kit
//
//  Created by Ben Smiley-Andrews on 28/01/2013.
//  Copyright (c) 2013 Ben Smiley-Andrews. All rights reserved.
//

#import "AudioUtility.h"

@implementation AudioController

#define bSampleRate 44100.0

-(id) init {
    if((self = [super init])) {
        
        NewAUGraph(&audioGraph);
        
        AudioComponentDescription cd;
        AUNode outputNode;
        
        cd.componentManufacturer = kAudioUnitManufacturer_Apple;
        cd.componentFlags = 0;
        cd.componentFlagsMask = 0;
        cd.componentType = kAudioUnitType_Output;
        cd.componentSubType = kAudioUnitSubType_RemoteIO;
        
        AUGraphAddNode(audioGraph, &cd, &outputNode);
        AUGraphNodeInfo(audioGraph, outputNode, &cd, &outputUnit);
        
        AUNode mixerNode;
        
        cd.componentManufacturer = kAudioUnitManufacturer_Apple;
        cd.componentFlags = 0;
        cd.componentFlagsMask = 0;
        cd.componentType = kAudioUnitType_Mixer;
        cd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
        
        AUGraphAddNode(audioGraph, &cd, &mixerNode);
        AUGraphNodeInfo(audioGraph, mixerNode, &cd, &mixerUnit);
        
        AUGraphConnectNodeInput(audioGraph, mixerNode, 0, outputNode, 0);
        
        AUGraphOpen(audioGraph);
        AUGraphInitialize(audioGraph);
        AUGraphStart(audioGraph);
        
        
        AUNode synthNode;
        
        cd.componentManufacturer = kAudioUnitManufacturer_Apple;
        cd.componentFlags = 0;
        cd.componentFlagsMask = 0;
        cd.componentType = kAudioUnitType_MusicDevice;
        cd.componentSubType = kAudioUnitSubType_MIDISynth;
       // cd.componentSubType = kAudioUnitSubType_DLSSynth;

        AUGraphAddNode(audioGraph, &cd, &synthNode);
        AUGraphNodeInfo(audioGraph, synthNode, &cd, &synthUnit);
        
        AUGraphConnectNodeInput(audioGraph, synthNode, 0, mixerNode, 0);
        
        
        
        
        AUGraphUpdate(audioGraph, NULL);

    }
    return self;
}

-(void) setInputVolume: (Float32) volume withBus: (AudioUnitElement) bus {
    OSStatus result = AudioUnitSetParameter(mixerUnit,
                                     kMultiChannelMixerParam_Volume,
                                     kAudioUnitScope_Input,
                                     bus,
                                     volume, 0);
    NSAssert (result == noErr, @"Unable to set mixer input volume. Error code: %d '%.4s'", (int) result, (const char *)&result);
}


-(void) noteOn:(Byte)note withVelocity:(UInt32)velocity
{
    MusicDeviceMIDIEvent(synthUnit, 0x90, note,  velocity, 0);
}
-(void) noteOff:(Byte)note {
    MusicDeviceMIDIEvent(synthUnit, 0x80, note, 0, 0);
}

-(void) noteOnFile:(Byte)note withVelocity:(UInt32)velocity
{
    MusicDeviceMIDIEvent(synthUnitFile, 0x90, note,  velocity, 0);
}
-(void) noteOffFile:(Byte)note {
    MusicDeviceMIDIEvent(synthUnitFile, 0x80, note, 0, 0);
}



@end
