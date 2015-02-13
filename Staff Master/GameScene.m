//
//  GameScene.m
//  Staff Master
//
//  Created by Taylor Moss on 1/23/15.
//  Copyright (c) 2015 MOSSTECH. All rights reserved.
//

#import "GameScene.h"
#import "GameData.h"
#import "Chord.h"
#import "Note.h"
#import "AudioUtility.h"
#import "MIDIUtility.h"

@implementation GameScene

const int NUMBER_OF_STAFF_LINES = 34;

static GameScene *_gameScene;

int _device;
NSString *_deviceSuffix;
GameData *_gameData;
NSArray *_chordCatalog;
AudioController *audioController;


//Menu
bool _screenIsMenu;

bool _didPressPlay;
bool _didReleasePlay;
bool _playIsPressed;

bool _didPressMidi;
bool _didReleaseMidi;
bool _midiIsPressed;

int _midiDeviceIndex;
SKLabelNode *_midiDeviceName;

//Key
bool _screenIsKey;

bool _didPressCMajor;
bool _didReleaseCMajor;
bool _cMajorIsPressed;

bool _didPressGMajor;
bool _didReleaseGMajor;
bool _gMajorIsPressed;

bool _didPressDMajor;
bool _didReleaseDMajor;
bool _dMajorIsPressed;

bool _didPressAMajor;
bool _didReleaseAMajor;
bool _aMajorIsPressed;

bool _didPressEMajor;
bool _didReleaseEMajor;
bool _eMajorIsPressed;

bool _didPressBMajor;
bool _didReleaseBMajor;
bool _bMajorIsPressed;

bool _didPressCFlatMajor;
bool _didReleaseCFlatMajor;
bool _cFlatMajorIsPressed;

bool _didPressFSharpMajor;
bool _didReleaseFSharpMajor;
bool _fSharpMajorIsPressed;

bool _didPressGFlatMajor;
bool _didReleaseGFlatMajor;
bool _gFlatMajorIsPressed;

bool _didPressCSharpMajor;
bool _didReleaseCSharpMajor;
bool _cSharpMajorIsPressed;

bool _didPressDFlatMajor;
bool _didReleaseDFlatMajor;
bool _dFlatMajorIsPressed;

bool _didPressAFlatMajor;
bool _didReleaseAFlatMajor;
bool _aFlatMajorIsPressed;

bool _didPressEFlatMajor;
bool _didReleaseEFlatMajor;
bool _eFlatMajorIsPressed;

bool _didPressBFlatMajor;
bool _didReleaseBFlatMajor;
bool _bFlatMajorIsPressed;

bool _didPressFMajor;
bool _didReleaseFMajor;
bool _fMajorIsPressed;

//Staff
bool _screenIsStaff;

bool _didPressTrebleStaff;
bool _didReleaseTrebleStaff;
bool _trebleStaffIsPressed;

bool _didPressBassStaff;
bool _didReleaseBassStaff;
bool _bassStaffIsPressed;

bool _didPressGrandStaff;
bool _didReleaseGrandStaff;
bool _grandStaffIsPressed;

//Notes
bool _screenIsNotes;

bool _didPressSingleNotes;
bool _didReleaseSingleNotes;
bool _singleNotesIsPressed;

bool _didPressMultipleNotes;
bool _didReleaseMultipleNotes;
bool _multipleNotesIsPressed;

bool _didPressCombinationNotes;
bool _didReleaseCombinationNotes;
bool _combinationNotesIsPressed;

bool _didReleaseNothing;

//Range
bool _screenIsLowRange;
bool _screenIsHighRange;

//Game
NSMutableArray *_notePressedFlags;
NSMutableArray *_fifoMidiEvents;

bool _screenIsGame;

NSArray *_currentNotes;

static inline CGPoint rotatedPosition(CGPoint startPosition, float distance, float radians){
    
    float xPosition = startPosition.x + distance*cosf(radians + M_PI/2);
    float yPosition = startPosition.y + distance*sinf(radians + M_PI/2);
    
    return CGPointMake(xPosition, yPosition);
    
}


-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
   
    
    _gameScene = self;
    audioController = [[AudioController alloc] init];
    
    
    
    _screenIsMenu = NO;
    _screenIsKey = NO;
    _screenIsStaff = NO;
    _screenIsNotes = NO;
    _screenIsLowRange = NO;
    _screenIsHighRange = NO;
    _screenIsGame = NO;
    
    
    _gameData = [[GameData alloc]init];
    _device = [self device];
    _deviceSuffix = [self deviceSuffix:_device];
   
    self.backgroundColor = [UIColor darkGrayColor];
    [self loadMenu];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //Menu
    if ([node.name isEqualToString:@"PlayButton"]) {
        _didPressPlay = YES;
        
    }
    else if ([node.name isEqualToString:@"MidiDeviceName"]) {
        _didPressMidi = YES;
        
    }
    
    //Key
    else if([node.name isEqualToString:@"CMajor"]){
        _didPressCMajor = YES;
    }
    else if ([node.name isEqualToString:@"GMajor"]){
        _didPressGMajor = YES;
    }
    else if ([node.name isEqualToString:@"DMajor"]){
        _didPressDMajor = YES;
    }
    else if ([node.name isEqualToString:@"AMajor"]){
        _didPressAMajor = YES;
    }
    else if ([node.name isEqualToString:@"EMajor"]){
        _didPressEMajor = YES;
    }
    else if ([node.name isEqualToString:@"BMajor"]){
        _didPressBMajor = YES;
    }
    else if ([node.name isEqualToString:@"CFlatMajor"]){
        _didPressCFlatMajor = YES;
    }
    else if ([node.name isEqualToString:@"FSharpMajor"]){
        _didPressFSharpMajor = YES;
    }
    else if ([node.name isEqualToString:@"GFlatMajor"]){
        _didPressGFlatMajor = YES;
    }
    else if ([node.name isEqualToString:@"CSharpMajor"]){
        _didPressCSharpMajor = YES;
    }
    else if ([node.name isEqualToString:@"DFlatMajor"]){
        _didPressDFlatMajor = YES;
    }
    else if ([node.name isEqualToString:@"AFlatMajor"]){
        _didPressAFlatMajor = YES;
    }
    else if ([node.name isEqualToString:@"EFlatMajor"]){
        _didPressEFlatMajor = YES;
    }
    else if ([node.name isEqualToString:@"BFlatMajor"]){
        _didPressBFlatMajor = YES;
    }
    else if ([node.name isEqualToString:@"GMajor"]){
        _didPressGMajor = YES;
    }
    else if ([node.name isEqualToString:@"FMajor"]){
        _didPressFMajor = YES;
    }
    
    //Staff
    else if ([node.name isEqualToString:@"TrebleStaff"]){
        _didPressTrebleStaff = YES;
    }
    else if ([node.name isEqualToString:@"BassStaff"]){
        _didPressBassStaff = YES;
    }
    else if ([node.name isEqualToString:@"GrandStaff"]){
        _didPressGrandStaff = YES;
    }
    
    //Notes
    else if ([node.name isEqualToString:@"SingleNotes"]){
        _didPressSingleNotes = YES;
    }
    else if ([node.name isEqualToString:@"MultipleNotes"]){
        _didPressMultipleNotes = YES;
    }
    else if ([node.name isEqualToString:@"CombinationNotes"]){
        _didPressCombinationNotes = YES;
    }
    
    //Range ***FOR TESTING ONLY***
    else if ([node.name isEqualToString:@"LowRange"]){
        //C2
        _gameData.lowRange = 60;
        [self transitionLowRangeToHighRange];
    }
    else if ([node.name isEqualToString:@"HighRange"]){
        //C4
        _gameData.highRange = 108;
        [self transitionHighRangeToGame];
    }
    
    else if(_screenIsGame){
        [self  removeGameNotes];
        [self loadNotesFromChord:_chordCatalog[arc4random_uniform((int)_chordCatalog.count - 1)]];
    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"PlayButton"]) {
        if (_playIsPressed == YES) {
            _didReleasePlay = YES;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"MidiDeviceName"]) {
        
        if (_midiIsPressed == YES) {
            _didReleaseMidi = YES;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"CMajor"]) {
        
        if (_cMajorIsPressed == YES) {
            _didReleaseCMajor = YES;
            _gameData.key = 0;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"GMajor"]) {
        if (_gMajorIsPressed == YES) {
            _didReleaseGMajor = YES;
            _gameData.key = 1;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"DMajor"]) {
        if (_dMajorIsPressed == YES) {
            _didReleaseDMajor = YES;
            _gameData.key = 2;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"AMajor"]) {
        if (_aMajorIsPressed == YES) {
            _didReleaseAMajor = YES;
            _gameData.key = 3;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"EMajor"]) {
        if (_eMajorIsPressed == YES) {
            _didReleaseEMajor = YES;
            _gameData.key = 4;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"BMajor"]) {
        if (_bMajorIsPressed == YES) {
            _didReleaseBMajor = YES;
            _gameData.key = 5;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"CFlatMajor"]) {
        if (_cFlatMajorIsPressed == YES) {
            _didReleaseCFlatMajor = YES;
            _gameData.key = -7;
            
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"FSharpMajor"]) {
        if (_fSharpMajorIsPressed == YES) {
            _didReleaseFSharpMajor = YES;
            _gameData.key = 6;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"GFlatMajor"]) {
        if (_gFlatMajorIsPressed == YES) {
            _didReleaseGFlatMajor = YES;
            _gameData.key = -6;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"CSharpMajor"]) {
        if (_cSharpMajorIsPressed == YES) {
            _didReleaseCSharpMajor = YES;
            _gameData.key = 7;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"DFlatMajor"]) {
        if (_dFlatMajorIsPressed == YES) {
            _didReleaseDFlatMajor = YES;
            _gameData.key = -5;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"AFlatMajor"]) {
        if (_aFlatMajorIsPressed == YES) {
            _didReleaseAFlatMajor = YES;
            _gameData.key = -4;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"EFlatMajor"]) {
        if (_eFlatMajorIsPressed == YES) {
            _didReleaseEFlatMajor = YES;
            _gameData.key = -3;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"BFlatMajor"]) {
        if (_bFlatMajorIsPressed == YES) {
            _didReleaseBFlatMajor = YES;
            _gameData.key = -2;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"FMajor"]) {
        if (_fMajorIsPressed == YES) {
            _didReleaseFMajor = YES;
            _gameData.key = -1;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"TrebleStaff"]) {
        if (_trebleStaffIsPressed == YES) {
            _didReleaseTrebleStaff = YES;
            _gameData.staff = 1;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"BassStaff"]) {
        if (_bassStaffIsPressed == YES) {
            _didReleaseBassStaff = YES;
            _gameData.staff = 0;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"GrandStaff"]) {
        if (_grandStaffIsPressed == YES) {
            _didReleaseGrandStaff = YES;
            _gameData.staff = 2;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"SingleNotes"]) {
        if (_singleNotesIsPressed == YES) {
            _didReleaseSingleNotes = YES;
            _gameData.notes = 0;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"MultipleNotes"]) {
        if (_multipleNotesIsPressed == YES) {
            _didReleaseMultipleNotes = YES;
            _gameData.notes = 1;
        }
        else{
            _didReleaseNothing = YES;
        }
    }
    else if ([node.name isEqualToString:@"CombinationNotes"]) {
        if (_combinationNotesIsPressed == YES) {
            _didReleaseCombinationNotes = YES;
            _gameData.notes = 2;
        }
        else{
            _didReleaseNothing = YES;
        }
    }

    
    else{
        _didReleaseNothing = YES;
    }
    
    //write code for --if not pressed already, dont worry about this
    
    _playIsPressed = NO;
    _midiIsPressed = NO;
    
    _cMajorIsPressed = NO;
    _gMajorIsPressed = NO;
    _dMajorIsPressed = NO;
    _aMajorIsPressed = NO;
    _eMajorIsPressed = NO;
    _bMajorIsPressed = NO;
    _cFlatMajorIsPressed = NO;
    _fSharpMajorIsPressed = NO;
    _gFlatMajorIsPressed = NO;
    _cSharpMajorIsPressed = NO;
    _dFlatMajorIsPressed = NO;
    _aFlatMajorIsPressed = NO;
    _eFlatMajorIsPressed = NO;
    _bFlatMajorIsPressed = NO;
    _fMajorIsPressed = NO;
    
    _trebleStaffIsPressed = NO;
    _bassStaffIsPressed = NO;
    _grandStaffIsPressed = NO;
    
    _singleNotesIsPressed = NO;
    _multipleNotesIsPressed = NO;
    _combinationNotesIsPressed = NO;
    
    
}

-(void)setButtonFlagsFromCaller:(NSString*)caller andName:(NSString *)name andDidPress:(bool*)didPress andDidRelease:(bool*)didRelease andIsPressed:(bool*)isPressed{
    
    if (*didPress == YES){
        [self enumerateChildNodesWithName:name usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 0.5;
        }];
        *isPressed = YES;
        *didPress = NO;
    }
    if(*didRelease == YES){
        [self enumerateChildNodesWithName:name usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
            if ([caller  isEqual: @"Menu"]) {
                [self transitionMenuToKey];
            }
            else if ([caller  isEqual: @"Key"]){
                [self transitionKeyToStaff];
            }
            else if([caller  isEqual: @"Staff"]){
                [self transitionStaffToNotes];
                
            }
            else if([caller isEqual: @"Notes"]){
                [self transitionNotesToLowRange];
            }
            else if([caller isEqual:@"Midi"]){
                [self cycleMidiDevices];
            }
            
        }];
        *didRelease = NO;
    }
    
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

/*
 Determines Apple Device Model:
 0 - iPhone 5/5S
 1 - iPhone 6
 2 - iPhone 6 Plus
 */
-(int)device{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (screenSize.width == 320 && screenSize.height == 568) {
        NSLog(@"You are using an iPhone 5/5S");
        return 0;
    }
    else if (screenSize.width == 375 && screenSize.height == 667){
        NSLog(@"You are using an iPhone 6");
        return 1;
    }
    else if (screenSize.width == 414 && screenSize.height == 736){
        NSLog(@"You are using an iPhone 6 Plus");
        return 2;
    }
    else return 0;
}

-(NSString *)deviceSuffix:(int)device{
    
    switch (device) {
        case 0:
            return @"_5";
            break;
        case 1:
            return @"_6";
            break;
        case 2:
            return @"_6Plus";
            break;
        default:
            return @"_5";
            break;
    }
    
}

-(void) didSimulatePhysics{
    
    //write code for -- dont monitor if not on particular page
    [self monitorMenu];
    [self monitorKey];
    [self monitorStaff];
    [self monitorNotes];
    
    if(_didReleaseNothing == YES){
        //write code for -- if not pressed, dont enumerate
        
        [self enumerateChildNodesWithName:@"PlayButton" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"MidiDeviceName" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"CMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"GMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"DMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"AMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"EMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"BMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"CFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"FSharpMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"GFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"CSharpMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"DFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"AFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"EFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"BFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"FMajor" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"TrebleStaff" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"BassStaff" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"GrandStaff" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"SingleNotes" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"MultipleNotes" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        [self enumerateChildNodesWithName:@"CombinationNotes" usingBlock:^(SKNode *node, BOOL *stop){
            ((SKSpriteNode*)node).alpha = 1.0;
        }];
        _didReleaseNothing = NO;
    }
    
    if ((int)_fifoMidiEvents.count > 0) {
        
        [self handlePacketList:_fifoMidiEvents[_fifoMidiEvents.count -1]];
    }
}

#pragma mark - Menu

-(void)loadMenu{
    
    _screenIsMenu = YES;
    
    NSString *playButtonImageName = @"PlayButton";
    playButtonImageName = [playButtonImageName stringByAppendingString:_deviceSuffix];
    SKTexture *playButtonTexture = [SKTexture textureWithImageNamed:playButtonImageName];
    SKSpriteNode *playButtonSprite = [SKSpriteNode spriteNodeWithTexture:playButtonTexture];
    playButtonSprite.name = @"PlayButton";
    playButtonSprite.userInteractionEnabled = NO;
    playButtonSprite.xScale = 0.5;
    playButtonSprite.yScale = 0.5;
    playButtonSprite.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [self addChild:playButtonSprite];
    
    
    NSString *titleImageName = @"Title";
    titleImageName = [titleImageName stringByAppendingString:_deviceSuffix];
    SKTexture *titleTexture = [SKTexture textureWithImageNamed:titleImageName];
    SKSpriteNode *titleSprite = [SKSpriteNode spriteNodeWithTexture:titleTexture];
    titleSprite.name = @"Title";
    titleSprite.userInteractionEnabled = NO;
    titleSprite.xScale = 0.5;
    titleSprite.yScale = 0.5;
    titleSprite.position =  CGPointMake(0.5*self.size.width, 0.8*self.size.height);
    [self addChild:titleSprite];
    
    
    NSString *panelImageName = @"Panel";
    panelImageName = [panelImageName stringByAppendingString:_deviceSuffix];
    SKTexture *panelTexture = [SKTexture textureWithImageNamed:panelImageName];
    SKSpriteNode *panelSprite = [SKSpriteNode spriteNodeWithTexture:panelTexture];
    panelSprite.name = @"Panel";
    panelSprite.userInteractionEnabled = NO;
    panelSprite.xScale = 0.5;
    panelSprite.yScale = 0.5;
    panelSprite.position = CGPointMake(0.5*self.size.width, 0.5*panelSprite.size.height);
    [self addChild:panelSprite];
    

    
    _midiDeviceName = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _midiDeviceName.name = @"MidiDeviceName";
    _midiDeviceName.fontSize = 0.5*panelSprite.size.height;
    _midiDeviceName.position = CGPointMake(0.5*self.size.width, 0.5*panelSprite.size.height - 0.4*_midiDeviceName.fontSize);
    _midiDeviceName.text = _gameData.selectedDevice.name;
    
    [self addChild:_midiDeviceName];
}



-(void)monitorMenu{
    
    [self setButtonFlagsFromCaller:@"Menu" andName:@"PlayButton" andDidPress:&_didPressPlay andDidRelease:&_didReleasePlay andIsPressed:&_playIsPressed];
    
    [self setButtonFlagsFromCaller:@"Midi" andName:@"MidiDeviceName" andDidPress:&_didPressMidi andDidRelease:&_didReleaseMidi andIsPressed:&_midiIsPressed];
    
}

-(void)cycleMidiDevices{
    
    [_gameData refreshMidiDevices];
    
    int numberOfMidiDevices = (int)_gameData.midiDevices.count;
    if (numberOfMidiDevices > 0) {
        if (_midiDeviceIndex < numberOfMidiDevices - 1 ) {
            _midiDeviceIndex ++;
            
        }
        else{
            _midiDeviceIndex = 0;
        }
        
        [_gameData setSelectedDeviceWithIndex:_midiDeviceIndex];
        
        
    }
    else{
        [_gameData setSelectedDeviceToNone];
    }
    _midiDeviceName.text = _gameData.selectedDevice.name;
    
    
}



-(void)killMenu{
    
    
    _screenIsMenu = NO;
    
    [self enumerateChildNodesWithName:@"PlayButton" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    
    [self enumerateChildNodesWithName:@"Title" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    
    //Register Selected Midi Device and initialize array to hold information about which notes are currently pressed
    [MIDIUtility setupDeviceWithCallBack:midiInputCallback];
    _notePressedFlags = [[NSMutableArray alloc]init];
    _fifoMidiEvents = [[NSMutableArray alloc]init];
}

-(void)transitionMenuToKey{
    [self killMenu];
    [self loadKey];
}



#pragma mark - Key



-(void)loadKey{
    
    _screenIsKey = YES;
    
    NSString *majorButtonImageName = @"Major";
    majorButtonImageName = [majorButtonImageName stringByAppendingString:_deviceSuffix];
    SKTexture *majorButtonTexture = [SKTexture textureWithImageNamed:majorButtonImageName];
    SKSpriteNode *majorButtonSprite = [SKSpriteNode spriteNodeWithTexture:majorButtonTexture];
    majorButtonSprite.name = @"Major";
    majorButtonSprite.userInteractionEnabled = NO;
    majorButtonSprite.xScale = 0.5;
    majorButtonSprite.yScale = 0.5;
    majorButtonSprite.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [self addChild:majorButtonSprite];
    
    [self loadKeyNodeWithName:@"CMajor" andRotation:-0*M_PI/6];
    [self loadKeyNodeWithName:@"GMajor" andRotation:-1*M_PI/6];
    [self loadKeyNodeWithName:@"DMajor" andRotation:-2*M_PI/6];
    [self loadKeyNodeWithName:@"AMajor" andRotation:-3*M_PI/6];
    [self loadKeyNodeWithName:@"EMajor" andRotation:-4*M_PI/6];
    [self loadKeyNodeWithName:@"BMajor" andRotation:-4.75*M_PI/6];
    [self loadKeyNodeWithName:@"CFlatMajor" andRotation:-5.25*M_PI/6];
    [self loadKeyNodeWithName:@"FSharpMajor" andRotation:-5.75*M_PI/6];
    [self loadKeyNodeWithName:@"GFlatMajor" andRotation:-6.25*M_PI/6];
    [self loadKeyNodeWithName:@"CSharpMajor" andRotation:-6.75*M_PI/6];
    [self loadKeyNodeWithName:@"DFlatMajor" andRotation:-7.25*M_PI/6];
    [self loadKeyNodeWithName:@"AFlatMajor" andRotation:-8*M_PI/6];
    [self loadKeyNodeWithName:@"EFlatMajor" andRotation:-9*M_PI/6];
    [self loadKeyNodeWithName:@"BFlatMajor" andRotation:-10*M_PI/6];
    [self loadKeyNodeWithName:@"FMajor" andRotation:-11*M_PI/6];
}


-(void)loadKeyNodeWithName:(NSString *)name andRotation:(float)radians{
    
    CGPoint circleCenter = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    double radius = 0.5*(self.size.width - (1.0/16.0)*self.size.width) - 1;
    
    NSString *imageName = [name stringByAppendingString:_deviceSuffix];
    SKTexture *nodeTexture = [SKTexture textureWithImageNamed:imageName];
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:nodeTexture];
    node.name = name;
    node.userInteractionEnabled = NO;
    node.xScale = 0.5;
    node.yScale = 0.5;
    node.position = rotatedPosition(circleCenter, radius - 0.5*node.size.height, radians);
    node.zRotation = radians;
    [self addChild:node];
    
}

-(void)monitorKey{
    
    [self setButtonFlagsFromCaller:@"Key" andName:@"CMajor" andDidPress:&_didPressCMajor andDidRelease:&_didReleaseCMajor andIsPressed:&_cMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"GMajor" andDidPress:&_didPressGMajor andDidRelease:&_didReleaseGMajor andIsPressed:&_gMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"DMajor" andDidPress:&_didPressDMajor andDidRelease:&_didReleaseDMajor andIsPressed:&_dMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"AMajor" andDidPress:&_didPressAMajor andDidRelease:&_didReleaseAMajor andIsPressed:&_aMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"EMajor" andDidPress:&_didPressEMajor andDidRelease:&_didReleaseEMajor andIsPressed:&_eMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"BMajor" andDidPress:&_didPressBMajor andDidRelease:&_didReleaseBMajor andIsPressed:&_bMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"CFlatMajor" andDidPress:&_didPressCFlatMajor andDidRelease:&_didReleaseCFlatMajor andIsPressed:&_cFlatMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"FSharpMajor" andDidPress:&_didPressFSharpMajor andDidRelease:&_didReleaseFSharpMajor andIsPressed:&_fSharpMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"GFlatMajor" andDidPress:&_didPressGFlatMajor andDidRelease:&_didReleaseGFlatMajor andIsPressed:&_gFlatMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"CSharpMajor" andDidPress:&_didPressCSharpMajor andDidRelease:&_didReleaseCSharpMajor andIsPressed:&_cSharpMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"DFlatMajor" andDidPress:&_didPressDFlatMajor andDidRelease:&_didReleaseDFlatMajor andIsPressed:&_dFlatMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"AFlatMajor" andDidPress:&_didPressAFlatMajor andDidRelease:&_didReleaseAFlatMajor andIsPressed:&_aFlatMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"EFlatMajor" andDidPress:&_didPressEFlatMajor andDidRelease:&_didReleaseEFlatMajor andIsPressed:&_eFlatMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"BFlatMajor" andDidPress:&_didPressBFlatMajor andDidRelease:&_didReleaseBFlatMajor andIsPressed:&_bFlatMajorIsPressed ];
    [self setButtonFlagsFromCaller:@"Key" andName:@"FMajor" andDidPress:&_didPressFMajor andDidRelease:&_didReleaseFMajor andIsPressed:&_fMajorIsPressed ];
}


-(void)killKey{
    
    _screenIsKey = NO;
    
    [self enumerateChildNodesWithName:@"CMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"GMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"DMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"AMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"EMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"BMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"CFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"FSharpMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"GFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"CSharpMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"DFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"AFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"EFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"BFlatMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"FMajor" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"Major" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)transitionKeyToStaff{
    [self killKey];
    [self loadStaff];
}

#pragma mark - Staff

-(void)loadStaff{
    
    _screenIsStaff = YES;
    
    float adjustedHeight = 0.9*self.size.height;
    CGPoint adjustedCenter =CGPointMake(0.5*self.size.width, 0.1*self.size.height + 0.50 * adjustedHeight);
    
    SKSpriteNode *trebleStaffButtonNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"TrebleStaff" stringByAppendingString:_deviceSuffix]]];
    trebleStaffButtonNode.name = @"TrebleStaff";
    trebleStaffButtonNode.xScale = 0.5;
    trebleStaffButtonNode.yScale = 0.5;
    trebleStaffButtonNode.position = CGPointMake(0.5*self.size.width, self.size.height - 0.5*(self.size.height - adjustedCenter.y - 0.5*trebleStaffButtonNode.size.height));
    [self addChild:trebleStaffButtonNode];
    
    SKSpriteNode *bassStaffButtonNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BassStaff" stringByAppendingString:_deviceSuffix]]];
    bassStaffButtonNode.name = @"BassStaff";
    bassStaffButtonNode.xScale = 0.5;
    bassStaffButtonNode.yScale = 0.5;
    bassStaffButtonNode.position = CGPointMake(0.5*self.size.width, 0.1*self.size.height + 0.50 * 0.9*self.size.height);
    [self addChild:bassStaffButtonNode];
    
    SKSpriteNode *grandStaffButtonNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"GrandStaff" stringByAppendingString:_deviceSuffix]]];
    grandStaffButtonNode.name = @"GrandStaff";
    grandStaffButtonNode.xScale = 0.5;
    grandStaffButtonNode.yScale = 0.5;
    grandStaffButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*((adjustedCenter.y - 0.5*grandStaffButtonNode.size.height) + 0.1*self.size.height));
    [self addChild:grandStaffButtonNode];
    
}
    


-(void)monitorStaff{
    [self setButtonFlagsFromCaller:@"Staff" andName:@"TrebleStaff" andDidPress:&_didPressTrebleStaff andDidRelease:&_didReleaseTrebleStaff andIsPressed:&_trebleStaffIsPressed ];
    [self setButtonFlagsFromCaller:@"Staff" andName:@"BassStaff" andDidPress:&_didPressBassStaff andDidRelease:&_didReleaseBassStaff andIsPressed:&_bassStaffIsPressed ];
    [self setButtonFlagsFromCaller:@"Staff" andName:@"GrandStaff" andDidPress:&_didPressGrandStaff andDidRelease:&_didReleaseGrandStaff andIsPressed:&_grandStaffIsPressed ];
}

-(void)killStaff{
    
    _screenIsStaff = NO;
    
    [self enumerateChildNodesWithName:@"TrebleStaff" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"BassStaff" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"GrandStaff" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)transitionStaffToNotes{
    [self killStaff];
    [self loadNotes];
}

#pragma mark - Notes

-(void)loadNotes{
    
    _screenIsNotes = YES;
    
    float adjustedHeight = 0.9*self.size.height;
    CGPoint adjustedCenter =CGPointMake(0.5*self.size.width, 0.1*self.size.height + 0.50 * adjustedHeight);
    
    SKSpriteNode *trebleStaffButtonNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"SingleNotes" stringByAppendingString:_deviceSuffix]]];
    trebleStaffButtonNode.name = @"SingleNotes";
    trebleStaffButtonNode.xScale = 0.5;
    trebleStaffButtonNode.yScale = 0.5;
    trebleStaffButtonNode.position = CGPointMake(0.5*self.size.width, self.size.height - 0.5*(self.size.height - adjustedCenter.y - 0.5*trebleStaffButtonNode.size.height));
    [self addChild:trebleStaffButtonNode];
    
    SKSpriteNode *bassStaffButtonNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"MultipleNotes" stringByAppendingString:_deviceSuffix]]];
    bassStaffButtonNode.name = @"MultipleNotes";
    bassStaffButtonNode.xScale = 0.5;
    bassStaffButtonNode.yScale = 0.5;
    bassStaffButtonNode.position = CGPointMake(0.5*self.size.width, 0.1*self.size.height + 0.50 * 0.9*self.size.height);
    [self addChild:bassStaffButtonNode];
    
    SKSpriteNode *grandStaffButtonNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"CombinationNotes" stringByAppendingString:_deviceSuffix]]];
    grandStaffButtonNode.name = @"CombinationNotes";
    grandStaffButtonNode.xScale = 0.5;
    grandStaffButtonNode.yScale = 0.5;
    grandStaffButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*((adjustedCenter.y - 0.5*grandStaffButtonNode.size.height) + 0.1*self.size.height));
    [self addChild:grandStaffButtonNode];
    
}

-(void)monitorNotes{
    [self setButtonFlagsFromCaller:@"Notes" andName:@"SingleNotes" andDidPress:&_didPressSingleNotes andDidRelease:&_didReleaseSingleNotes andIsPressed:&_singleNotesIsPressed ];
    [self setButtonFlagsFromCaller:@"Notes" andName:@"MultipleNotes" andDidPress:&_didPressMultipleNotes andDidRelease:&_didReleaseMultipleNotes andIsPressed:&_multipleNotesIsPressed ];
    [self setButtonFlagsFromCaller:@"Notes" andName:@"CombinationNotes" andDidPress:&_didPressCombinationNotes andDidRelease:&_didReleaseCombinationNotes andIsPressed:&_combinationNotesIsPressed ];
    
}

-(void)killNotes{
    
    _screenIsNotes = NO;
    
    [self enumerateChildNodesWithName:@"SingleNotes" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"MultipleNotes" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"CombinationNotes" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    
    
}
-(void)transitionNotesToLowRange{
    [self killNotes];
    [self loadLowRange];
}

#pragma mark - Range

-(void)loadLowRange{
    
    _screenIsLowRange = YES;
    
    SKSpriteNode *LowRangeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"LowRange" stringByAppendingString:_deviceSuffix]]];
    LowRangeNode.name = @"LowRange";
    LowRangeNode.xScale = 0.5;
    LowRangeNode.yScale = 0.5;
    LowRangeNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [self addChild:LowRangeNode];
}

-(void)killLowRange{
    _screenIsLowRange = NO;
    [self enumerateChildNodesWithName:@"LowRange" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    

}

-(void)transitionLowRangeToHighRange{
    [self killLowRange];
    [self loadHighRange];
}

-(void)loadHighRange{
    _screenIsHighRange = YES;
    SKSpriteNode *LowRangeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"HighRange" stringByAppendingString:_deviceSuffix]]];
    LowRangeNode.name = @"HighRange";
    LowRangeNode.xScale = 0.5;
    LowRangeNode.yScale = 0.5;
    LowRangeNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [self addChild:LowRangeNode];
}

-(void)killHighRange{
    
    _screenIsHighRange = NO;
    
    [self enumerateChildNodesWithName:@"HighRange" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    
    [self enumerateChildNodesWithName:@"Panel" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)transitionHighRangeToGame{
    [self killHighRange];
    [self buildChordCatalog];
    [self loadGame];
}

#pragma mark - Game

-(void)loadGame{
    
    _screenIsGame = YES;
    [_notePressedFlags removeAllObjects];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 7*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 8*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 9*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 10*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 11*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 21*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 22*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 23*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 24*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
    [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, 25*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];

    SKSpriteNode *bassClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BassClef" stringByAppendingString:_deviceSuffix]]];
    bassClef.name = @"BassClef";
    bassClef.xScale = 0.5;
    bassClef.yScale = 0.5;
    bassClef.position = CGPointMake(0.1*self.size.width, 9.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
    [self addChild:bassClef];
    
    SKSpriteNode *trebleClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"TrebleClef" stringByAppendingString:_deviceSuffix]]];
    trebleClef.name = @"TrebleClef";
    trebleClef.xScale = 0.5;
    trebleClef.yScale = 0.5;
    trebleClef.position = CGPointMake(0.1*self.size.width, 23*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
    [self addChild:trebleClef];
    
    
   
    
    [self loadNotesFromChord:_chordCatalog[arc4random_uniform((int)_chordCatalog.count - 1)]];
}

-(void)monitorGame{
    
}

-(void)removeGameNotes{
    [self enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)loadStaffLineWithPosition:(CGPoint)position{
    SKSpriteNode *staffLine = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"StaffLine" stringByAppendingString:_deviceSuffix]]];
    staffLine.name = @"StaffLine";
    staffLine.xScale = 0.5;
    staffLine.yScale = 0.5;
    staffLine.position = position;
    [self addChild:staffLine];
    
}

-(void)loadNotesFromChord:(Chord*)chord{
    
    NSArray *notes = chord.notes;
    _currentNotes = notes;
    
    for (int i =0; i <notes.count; i++) {
        Note *note = notes[i];
        CGPoint position;
        
        if (note.staff == 0) {
            position = CGPointMake(0.5*self.size.width, 0.5*note.position*self.size.height/(NUMBER_OF_STAFF_LINES + 1) + 0.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
            //NSLog(@"%i",note.note);
        }
        else
        {
            position = CGPointMake(0.5*self.size.width, 0.5*(note.position + 16)*self.size.height/(NUMBER_OF_STAFF_LINES + 1) + 0.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
            //NSLog(@"%i",note.note);
        }
     
        SKSpriteNode *noteNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"Note" stringByAppendingString:_deviceSuffix]]];
        noteNode.name = @"Note";
        noteNode.xScale = 0.5;
        noteNode.yScale = 0.5;
        noteNode.position = position;
        [self addChild:noteNode];
    
    }
}

-(void)buildChordCatalog{
    NSArray *chordArray;
    
    switch (_gameData.key) {
        case 0:
            chordArray = [self arrayFromPropertyList:[[NSBundle mainBundle] pathForResource:@"Chords0" ofType:@"plist"]] ;
            _chordCatalog = [self chordCatalogFromChordArray:chordArray];
            break;
            
        default:NSLog(@"Error selecting chord");
            break;
    }
    
}

-(NSArray*)arrayFromPropertyList:(NSString*)list{
    
    return [NSArray arrayWithContentsOfFile:list];
    
}

-(NSArray *)chordCatalogFromChordArray:(NSArray*)chordArray{
    
    NSMutableArray *chordCatalog;
    chordCatalog = [[NSMutableArray alloc]init];
    
    for (int i =0; i < chordArray.count; i++) {
        
        bool includeChord = NO;
        
        NSDictionary *chordDictionary = chordArray[i];
        NSArray *notesArray = [chordDictionary objectForKey:@"Notes"];
        
        
        if (_gameData.staff == [[chordDictionary objectForKey:@"Staff"] intValue] || _gameData.staff == 2) {
        
            for (int j = 0; j < notesArray.count; j++) {
                
                NSDictionary *noteDictionary = notesArray[j];
                
                if ([[noteDictionary objectForKey:@"Note"] intValue] < _gameData.lowRange) {
                    includeChord = NO;
                    break;
                }
                else if([[noteDictionary objectForKey:@"Note"] intValue] > _gameData.highRange) {
                    includeChord = NO;
                    break;
                }
                else{
                    includeChord = YES;
                }
            }
        }
        
        if (includeChord == YES) {
            
            Chord *chord = [[Chord alloc]init];

            
            NSMutableArray *notes = [[NSMutableArray alloc]init];
            
            for (int j = 0; j < notesArray.count; j++) {
                NSDictionary *noteDictionary = notesArray[j];
                
                Note *note = [[Note alloc]init];
                note.note = [[noteDictionary objectForKey:@"Note"] intValue];
                note.position = [[noteDictionary objectForKey:@"Position"] intValue];
                note.symbol = [[noteDictionary objectForKey:@"Symbol"] intValue];
                note.staff = [[noteDictionary objectForKey:@"Staff"] intValue];
            
                [notes addObject:note];
            }
            
            chord.name = [chordDictionary objectForKey:@"Name"];
            chord.staff = [[chordDictionary objectForKey:@"Staff"] intValue];
            chord.variation = [[chordDictionary objectForKey:@"Variation"] intValue];
            chord.inversion = [[chordDictionary objectForKey:@"Inversion"] intValue];
            chord.notes = notes;
            
            [chordCatalog addObject:chord];
            
        }
    }
    
    return chordCatalog;
    
}


void midiInputCallback (const MIDIPacketList *list,
                        void *procRef,
                        void *srcRef)
{
    
    
    
    [_gameScene addPacketListToFifo:list];
    [MIDIUtility processMessage:list];
    
    
    

    
}

-(void)addPacketListToFifo:(const MIDIPacketList*)list{
    
    [ _fifoMidiEvents addObject:[NSValue value:&list withObjCType:@encode(const MIDIPacketList*)]];
}

-(void)handlePacketList:(NSValue*)packetList{
    
    //Reconstruct MIDIPacketList from NSValue
    MIDIPacketList *midiPacketList;
    [packetList getValue:&midiPacketList];
    
    //Set the Lowest Note the game will display
    if (_screenIsLowRange) {
        _gameData.lowRange = [MIDIUtility getNoteNumber:midiPacketList];
    }
    //Set the Highest Note the game will display
    else if(_screenIsHighRange) {
        _gameData.highRange = [MIDIUtility getNoteNumber:midiPacketList];
    }
    //Check if note on or note off
    else if (_screenIsGame) {
        if([MIDIUtility getMessageType:midiPacketList] == 0x90)
            [self checkNoteHitWithNumber:[MIDIUtility getNoteNumber:midiPacketList]];
        else if ([MIDIUtility getMessageType:midiPacketList] == 0x80)
            [self checkNoteReleaseWithNumber:[MIDIUtility getNoteNumber:midiPacketList]];
    }

    
    
    [_fifoMidiEvents removeObjectAtIndex:_fifoMidiEvents.count - 1];
    
}

-(void)checkNoteHitWithNumber:(int)userKeyNumber
{
    
    [_notePressedFlags addObject: [NSNumber numberWithInt:userKeyNumber]];
    
    
    bool correctPlay = NO;
    
    for (int i = 0; i < (int)_currentNotes.count; i++) {
        correctPlay = NO;
        Note *note = _currentNotes[i];
        for (int j = 0; j < (int)_notePressedFlags.count; j++) {
            if (note.note == [_notePressedFlags[j] intValue]) {
                correctPlay = YES;
                break;
            }
            else
            {
                correctPlay = NO;
            }
        }
        if (!correctPlay) {
            break;
        }
       
    }

    
    
    
    if (correctPlay) {
        [self removeGameNotes];
        [self loadNotesFromChord:_chordCatalog[arc4random_uniform((int)_chordCatalog.count - 1)]];
    }
    
    
    
}

-(void)checkNoteReleaseWithNumber:(int)userKeyNumber
{
    
    if (_notePressedFlags.count > 0) {
        for (int i = 0; i < (int)_notePressedFlags.count; i++) {
            if ([_notePressedFlags[i] intValue] == userKeyNumber) {
                [_notePressedFlags removeObjectAtIndex:i];
            }
        }
    }
    
}




@end
