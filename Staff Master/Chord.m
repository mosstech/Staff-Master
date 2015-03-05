//
//  Chord.m
//  Staff Master
//
//  Created by Taylor Moss on 2/28/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import "Chord.h"
#import "Note.h"


@implementation Chord

@dynamic name;
@dynamic key;
@dynamic octave;
@dynamic inversion;
@dynamic staff;
@dynamic notes;

-(bool)noteOverlapForNote:(Note*)note{
    bool overlap = false;
    for (Note *noteInChord in self.notes) {
        if (note != noteInChord) {
            if ([noteInChord staffLocation] + 1 == [note staffLocation]) {
                overlap = true;
            }
        }
        
    }
    return overlap;
}

-(bool)accidentalOverlapForNote:(Note*)note{
    NSLog(@"note: %@", note.name);
    bool overlap = NO;
    for (Note *noteInChord in self.notes) {
        
        if (note != noteInChord) {
            if ([note staffLocation] - [noteInChord staffLocation] <= 2 && [note staffLocation] - [noteInChord staffLocation] > 0) {
                if (![self accidentalOverlapForNote:noteInChord]) {
                    overlap = YES;
                }
                
            }
        }
    }
    
    return overlap;
    
}

-(int)centeredLedgerLinesBelowBassClef{
    int linesBelowBassClef = 0;
    for (Note *noteInChord in self.notes) {
        if ((13 - noteInChord.staffLocation) > linesBelowBassClef ) {
            linesBelowBassClef = 13 - noteInChord.staffLocation;
        }
    }
    return linesBelowBassClef;
}

-(int)shiftedLedgerLinesBelowBassClef{
    int linesBelowBassClef = 0;
    for (Note *noteInChord in self.notes) {
        if ([self noteOverlapForNote:noteInChord]) {
            if ((13 - noteInChord.staffLocation) > linesBelowBassClef ) {
                linesBelowBassClef = 13 - noteInChord.staffLocation;
            }
        }
    }
    return linesBelowBassClef;
}

-(int)centeredLedgerLinesAboveBassClef{
    int linesAboveBassClef = 0;
    for (Note *noteInChord in self.notes) {
        if ((noteInChord.staffLocation - 21) > linesAboveBassClef ) {
            linesAboveBassClef = noteInChord.staffLocation - 21;
        }
    }
    return linesAboveBassClef;
}

-(int)shiftedLedgerLinesAboveBassClef{
    int linesAboveBassClef = 0;
    for (Note *noteInChord in self.notes) {
        if ([self noteOverlapForNote:noteInChord]) {
            if ((noteInChord.staffLocation - 21) > linesAboveBassClef ) {
                linesAboveBassClef = noteInChord.staffLocation - 21;
            }
        }
    }
    return linesAboveBassClef;
}

-(int)centeredLedgerLinesBelowTrebleClef{
    int linesBelowTrebleClef = 0;
    for (Note *noteInChord in self.notes) {
        if ((25 - noteInChord.staffLocation) > linesBelowTrebleClef ) {
            linesBelowTrebleClef = 25 - noteInChord.staffLocation;
        }
    }
    return linesBelowTrebleClef;
}

-(int)shiftedLedgerLinesBelowTrebleClef{
    int linesBelowTrebleClef = 0;
    for (Note *noteInChord in self.notes) {
        if ([self noteOverlapForNote:noteInChord]) {
            if ((25 - noteInChord.staffLocation) > linesBelowTrebleClef ) {
                linesBelowTrebleClef = 25 - noteInChord.staffLocation;
            }
        }
    }
    return linesBelowTrebleClef;
}

-(int)centeredLedgerLinesAboveTrebleClef{
    int linesAboveTrebleClef = 0;
    for (Note *noteInChord in self.notes) {
        if ((noteInChord.staffLocation - 33) > linesAboveTrebleClef ) {
            linesAboveTrebleClef = noteInChord.staffLocation - 33;
        }
    }
    return linesAboveTrebleClef;
}

-(int)shiftedLedgerLinesAboveTrebleClef{
    int linesAboveTrebleClef = 0;
    for (Note *noteInChord in self.notes) {
        if ([self noteOverlapForNote:noteInChord]) {
            if ((noteInChord.staffLocation - 33) > linesAboveTrebleClef ) {
                linesAboveTrebleClef = noteInChord.staffLocation - 33;
            }
        }
    }
    return linesAboveTrebleClef;
}

@end
