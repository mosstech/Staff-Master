//
//  MIDIPacketObject.h
//  Staff Master
//
//  Created by Taylor Moss on 2/8/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIDIPacketObject : NSObject
@property UInt64 timeStamp;
@property UInt16 length;
@property Byte data;

@end
