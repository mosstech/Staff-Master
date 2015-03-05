//
//  Note.m
//  Staff Master
//
//  Created by Taylor Moss on 2/28/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import "Note.h"
#import "Chord.h"


@implementation Note

@dynamic intonation;
@dynamic name;
@dynamic accidental;
@dynamic staff;
@dynamic chord;
@dynamic octave;

-(int)midiNumber{
    if ([self.octave intValue] == 0) {
        if ([self.name isEqualToString:@"A"]) return 21 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 23 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 1) {
        if ([self.name isEqualToString:@"C"]) return 24 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 26 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 28 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 29 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 31 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 33 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 35 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 2) {
        if ([self.name isEqualToString:@"C"]) return 36 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 38 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 40 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 41 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 43 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 45 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 47 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 3) {
        if ([self.name isEqualToString:@"C"]) return 48 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 50 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 52 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 53 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 55 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 57 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 59 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 4) {
        if ([self.name isEqualToString:@"C"]) return 60 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 62 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 64 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 65 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 67 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 69 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 71 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 5) {
        if ([self.name isEqualToString:@"C"]) return 72 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 74 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 76 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 77 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 79 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 81 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 83 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 6) {
        if ([self.name isEqualToString:@"C"]) return 84 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 86 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 88 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 89 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 91 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 93 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 95 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 7) {
        if ([self.name isEqualToString:@"C"]) return 96 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"D"]) return 98 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"E"]) return 100 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"F"]) return 101 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"G"]) return 103 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"A"]) return 105 + [self.intonation intValue];
        else if ([self.name isEqualToString:@"B"]) return 107 + [self.intonation intValue];
        else return 0;
    }
    if ([self.octave intValue] == 8) {
        if ([self.name isEqualToString:@"C"]) return 96 + [self.intonation intValue];
        else return 0;
    }
   
    else return 0;
}

-(int)staffLocation{
    if ([self.octave intValue] == 0) {
        if ([self.name isEqualToString:@"A"]) return 0;
        else if ([self.name isEqualToString:@"B"]) return 1;
        else return 0;
    }
    if ([self.octave intValue] == 1) {
        if ([self.name isEqualToString:@"C"]) return 2;
        else if ([self.name isEqualToString:@"D"]) return 3;
        else if ([self.name isEqualToString:@"E"]) return 4;
        else if ([self.name isEqualToString:@"F"]) return 5;
        else if ([self.name isEqualToString:@"G"]) return 6;
        else if ([self.name isEqualToString:@"A"]) return 7;
        else if ([self.name isEqualToString:@"B"]) return 8;
        else return 0;
    }
    if ([self.octave intValue] == 2) {
        if ([self.name isEqualToString:@"C"]) return 9;
        else if ([self.name isEqualToString:@"D"]) return 10;
        else if ([self.name isEqualToString:@"E"]) return 11;
        else if ([self.name isEqualToString:@"F"]) return 12;
        else if ([self.name isEqualToString:@"G"]) return 13;
        else if ([self.name isEqualToString:@"A"]) return 14;
        else if ([self.name isEqualToString:@"B"]) return 15;
        else return 0;
    }
    if ([self.octave intValue] == 3) {
        if ([self.name isEqualToString:@"C"]) return 16;
        else if ([self.name isEqualToString:@"D"]) return 17;
        else if ([self.name isEqualToString:@"E"]) return 18;
        else if ([self.name isEqualToString:@"F"]) return 19;
        else if ([self.name isEqualToString:@"G"]) return 20;
        else if ([self.name isEqualToString:@"A"]) return 21;
        else if ([self.name isEqualToString:@"B"]) return 22;
        else return 0;
    }
    if ([self.octave intValue] == 4) {
        if ([self.name isEqualToString:@"C"]) return 23;
        else if ([self.name isEqualToString:@"D"]) return 24;
        else if ([self.name isEqualToString:@"E"]) return 25;
        else if ([self.name isEqualToString:@"F"]) return 26;
        else if ([self.name isEqualToString:@"G"]) return 27;
        else if ([self.name isEqualToString:@"A"]) return 28;
        else if ([self.name isEqualToString:@"B"]) return 29;
        else return 0;
    }
    if ([self.octave intValue] == 5) {
        if ([self.name isEqualToString:@"C"]) return 30;
        else if ([self.name isEqualToString:@"D"]) return 31;
        else if ([self.name isEqualToString:@"E"]) return 32;
        else if ([self.name isEqualToString:@"F"]) return 33;
        else if ([self.name isEqualToString:@"G"]) return 34;
        else if ([self.name isEqualToString:@"A"]) return 35;
        else if ([self.name isEqualToString:@"B"]) return 36;
        else return 0;
    }
    if ([self.octave intValue] == 6) {
        if ([self.name isEqualToString:@"C"]) return 37;
        else if ([self.name isEqualToString:@"D"]) return 38;
        else if ([self.name isEqualToString:@"E"]) return 39;
        else if ([self.name isEqualToString:@"F"]) return 40;
        else if ([self.name isEqualToString:@"G"]) return 41;
        else if ([self.name isEqualToString:@"A"]) return 42;
        else if ([self.name isEqualToString:@"B"]) return 43;
        else return 0;
    }
    if ([self.octave intValue] == 7) {
        if ([self.name isEqualToString:@"C"]) return 44;
        else if ([self.name isEqualToString:@"D"]) return 45;
        else if ([self.name isEqualToString:@"E"]) return 46;
        else if ([self.name isEqualToString:@"F"]) return 47;
        else if ([self.name isEqualToString:@"G"]) return 48;
        else if ([self.name isEqualToString:@"A"]) return 49;
        else if ([self.name isEqualToString:@"B"]) return 50;
        else return 0;
    }
    if ([self.octave intValue] == 8) {
        if ([self.name isEqualToString:@"C"]) return 51;
        else return 0;
    }
    
    else return 0;
}
@end
