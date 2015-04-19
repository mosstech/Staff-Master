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
#import "SpriteButton.h"
#import "AppDelegate.h"

@implementation GameScene

{
    int _device;
    NSString *_deviceSuffix;
    GameData *_gameData;
    NSArray *_chordCatalog;
    AudioController *audioController;
    NSUserDefaults *_userDefaults;
    SKNode *_menuScreenNode;
    SKNode *_keyScreenNode;
    SKNode *_staffScreenNode;
    SKNode *_notesScreenNode;
    SKNode *_lowRangeScreenNode;
    SKNode *_highRangeScreenNode;
    SKNode *_gameScreenNode;
    SKNode *_scoreScreenNode;
    SKNode *_pausedScreenNode;
    
    enum currentScreen {kNothing = 0,
        kMenu = 1,
        kKey = 2,
        kStaff = 3,
        kNotes = 4,
        kLowRange = 5,
        kHighRange = 6,
        kGame = 7,
        kScore = 8};
    
    enum currentScreen _currentScreen;
    
    int _midiDeviceIndex;
    SKLabelNode *_midiDeviceName;
    
    
    NSMutableArray *_notePressedFlags;
    NSMutableArray *_fifoMidiEvents;
    NSSet *_currentNotes;
    
    SKLabelNode *_currentNameNode;
    SKLabelNode *_timeRemainingNode;
    SKLabelNode *_scoreNode;
    
    NSString *_currentName;
    int _timeRemaining;
    int _score;
    
    int _chordCatalogIncrementer;
}

const bool DEBUG_MODE = YES;

const int NUMBER_OF_STAFF_LINES = 34;
static GameScene *_gameScene;


static inline CGPoint rotatedPosition(CGPoint startPosition, float distance, float radians){
    
    float xPosition = startPosition.x + distance*cosf(radians + M_PI/2);
    float yPosition = startPosition.y + distance*sinf(radians + M_PI/2);
    
    return CGPointMake(xPosition, yPosition);
    
}

void midiInputCallback (const MIDIPacketList *list,
                        void *procRef,
                        void *srcRef)
{
    if (![_gameScene gameIsPaused]) {
        [_gameScene handlePacketList:list];
        [MIDIUtility processMessage:list];
    }
}

-(bool)gameIsPaused{
    return _gameData.isPaused;
}

-(void)didMoveToView:(SKView *)view {
   
    _currentScreen = kNothing;
    
    _gameScene = self;
    audioController = [[AudioController alloc] init];
    
    _gameData = [[GameData alloc]init];
    _device = [self device];
    _deviceSuffix = [self deviceSuffix:_device];
   
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _gameData.bestScore = (int)[_userDefaults integerForKey:@"BestScore"];
   
    _chordCatalogIncrementer = 0;
    
    [self loadMenu];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    
    if (_currentScreen == kMenu) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        if ([node.name isEqualToString:@"MidiDeviceNameLabel"]) {
            [self cycleMidiDevices];
            
        }
    }
    
    
    //used for testing only
    if (DEBUG_MODE) {
        if (_currentScreen == kLowRange) {
            _gameData.lowRange = 0;
            [self transitionLowRangeToHighRange];
        }
        else if (_currentScreen == kHighRange){
            _gameData.highRange = 108;
            [self transitionHighRangeToGame];
        }
        if (_currentScreen == kGame && !_gameData.isPaused) {
            [self removeGameNotes];
            _score = _score + 25*(int)_currentNotes.count;
            
            if (_chordCatalogIncrementer < _chordCatalog.count) {
                [self loadNotesFromChord:_chordCatalog[_chordCatalogIncrementer]];
                _chordCatalogIncrementer++;
            }
            else{
                _chordCatalogIncrementer = 0;
            }
            
            _scoreNode.text = [NSString stringWithFormat:@"%i",_score];
        }
    }
    
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
    
    
    if (_currentScreen == kGame) {
        
        if (_timeRemaining == 0) {
            [self transitionGameToScore];
        }
        
    }
    
}



#pragma mark - Menu

-(void)loadMenu{
    
    _currentScreen = kMenu;
    self.backgroundColor = [UIColor darkGrayColor];
    _menuScreenNode = [SKNode node];
    _menuScreenNode.name = @"MenuScreenNode";
    [self addChild:_menuScreenNode];
    
    NSString *playButtonImageName = @"PlayButton";
    playButtonImageName = [playButtonImageName stringByAppendingString:_deviceSuffix];
    SKTexture *playButtonTexture = [SKTexture textureWithImageNamed:playButtonImageName];
    SpriteButton *playButtonNode = [SpriteButton spriteNodeWithTexture:playButtonTexture];
    [playButtonNode setDefaults];
    playButtonNode.name = @"PlayButton";
    playButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    playButtonNode.delegate = self;
    [_menuScreenNode addChild:playButtonNode];
    
    NSString *bottomPanelImageName = @"Panel";
    bottomPanelImageName = [bottomPanelImageName stringByAppendingString:_deviceSuffix];
    SKTexture *bottomPanelTexture = [SKTexture textureWithImageNamed:bottomPanelImageName];
    SKSpriteNode *bottomPanelNode = [SKSpriteNode spriteNodeWithTexture:bottomPanelTexture];
    bottomPanelNode.xScale = 0.5;
    bottomPanelNode.yScale = 0.5;
    bottomPanelNode.name = @"BottomPanel";
    bottomPanelNode.position = CGPointMake(0.5*self.size.width, 0.5*bottomPanelNode.size.height);
    [_menuScreenNode addChild:bottomPanelNode];
    
    SKLabelNode *titleLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    titleLabelNode.name = @"TitleLabel";
    titleLabelNode.fontSize = 0.1*self.size.height;
    titleLabelNode.fontColor = [UIColor whiteColor];
    titleLabelNode.text = @"Staff Master";
    titleLabelNode.position = CGPointMake(0.5*self.size.width, 0.8*self.size.height);
    [_menuScreenNode addChild:titleLabelNode];
    

    _midiDeviceName = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _midiDeviceName.name = @"MidiDeviceNameLabel";
    _midiDeviceName.fontSize = 0.5*bottomPanelNode.size.height;
    _midiDeviceName.position = CGPointMake(0.5*self.size.width, 0.5*bottomPanelNode.size.height - 0.4*_midiDeviceName.fontSize);
    _midiDeviceName.text = _gameData.selectedDevice.name;
    [_menuScreenNode addChild:_midiDeviceName];
    
    
    SKSpriteNode *bestBannerNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"ScoreBanner" stringByAppendingString:_deviceSuffix]]];
    bestBannerNode.name = @"BestBanner";
    bestBannerNode.xScale = 0.5;
    bestBannerNode.yScale = 0.5;
    bestBannerNode.position = CGPointMake(0.5*self.size.width, playButtonNode.position.y - 0.5*playButtonNode.size.height - 1.5*bestBannerNode.size.height);
    [_menuScreenNode addChild:bestBannerNode];
    
    SKLabelNode *bestLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    bestLabelNode.name = @"Best";
    bestLabelNode.fontSize = 0.8*bestBannerNode.size.height;
    bestLabelNode.fontColor = [SKColor whiteColor];
    bestLabelNode.text = [NSString stringWithFormat:@"Best: %i",_gameData.bestScore];
    bestLabelNode.position =CGPointMake(0.5*self.size.width, bestBannerNode.position.y- 0.4*bestLabelNode.fontSize);
    [_menuScreenNode addChild:bestLabelNode];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeAlphaTo:0.5 duration:1.0],
                                           [SKAction fadeAlphaTo:1.0 duration:0.5]]];
    
    
    [_midiDeviceName runAction:[SKAction repeatActionForever:blink]];
    
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
    [_menuScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionMenuToKey{
    [self killMenu];
    [self loadKey];
}



#pragma mark - Key

-(void)loadKey{
    //Set current screen
    _currentScreen = kKey;
    
    //Register Selected Midi Device and initialize array to hold information about which notes are currently pressed
    [MIDIUtility setupDeviceWithCallBack:midiInputCallback];
    _notePressedFlags = [[NSMutableArray alloc]init];
    _fifoMidiEvents = [[NSMutableArray alloc]init];
    
    _keyScreenNode = [SKNode node];
    _keyScreenNode.name = @"KeyScreenNode";
    [self addChild:_keyScreenNode];
    
    SKLabelNode *majorButtonNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    majorButtonNode.name = @"Major";
    majorButtonNode.fontSize = 0.07*self.size.height;
    majorButtonNode.fontColor =[SKColor whiteColor];
    majorButtonNode.text = @"Major";
    majorButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height - 0.4*majorButtonNode.fontSize);
    [_keyScreenNode addChild:majorButtonNode];
    
    SpriteButton *backButton = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BackButton" stringByAppendingString:_deviceSuffix]]];
    [backButton setDefaults];
    backButton.name = @"BackButton";
    backButton.position = CGPointMake(0.5*backButton.size.width + 0.5*backButton.size.height, backButton.size.height);
    backButton.delegate = self;
    [_keyScreenNode addChild:backButton];
   
    
    //calls a function that creates and adds a button for each key
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
    SpriteButton *node = [SpriteButton spriteNodeWithTexture:nodeTexture];
    [node setDefaults];
    node.name = name;
    node.position = rotatedPosition(circleCenter, radius - 0.5*node.size.height, radians);
    node.zRotation = radians;
    node.delegate = self;
    [_keyScreenNode addChild:node];
}

-(void)killKey{
    
    [_keyScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionKeyToStaff{
    [self killKey];
    [self loadStaff];
}

-(void)transitionKeyToMenu{
    [self killKey];
    [self loadMenu];
}

#pragma mark - Staff

-(void)loadStaff{
    
    _currentScreen = kStaff;

    _staffScreenNode = [SKNode node];
    _staffScreenNode.name = @"StaffScreenNode";
    [self addChild:_staffScreenNode];

    
    
    SpriteButton *trebleStaffButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"TrebleStaff" stringByAppendingString:_deviceSuffix]]];
    [trebleStaffButtonNode setDefaults];
    trebleStaffButtonNode.name = @"TrebleStaff";
    int spaceBetweenButtons = (self.size.height - 3*trebleStaffButtonNode.size.height)/4;
    trebleStaffButtonNode.position = CGPointMake(0.5*self.size.width, 3*spaceBetweenButtons + 2.5*trebleStaffButtonNode.size.height);
    trebleStaffButtonNode.delegate = self;
    [_staffScreenNode addChild:trebleStaffButtonNode];
    
    SpriteButton *bassStaffButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BassStaff" stringByAppendingString:_deviceSuffix]]];
    [bassStaffButtonNode setDefaults];
    bassStaffButtonNode.name = @"BassStaff";
    bassStaffButtonNode.position = CGPointMake(0.5*self.size.width, 2*spaceBetweenButtons + 1.5*bassStaffButtonNode.size.height);
    bassStaffButtonNode.delegate = self;
    [_staffScreenNode addChild:bassStaffButtonNode];
    
    SpriteButton *grandStaffButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"GrandStaff" stringByAppendingString:_deviceSuffix]]];
    [grandStaffButtonNode setDefaults];
    grandStaffButtonNode.name = @"GrandStaff";
    grandStaffButtonNode.position = CGPointMake(0.5*self.size.width, 1*spaceBetweenButtons + 0.5*grandStaffButtonNode.size.height);
    grandStaffButtonNode.delegate = self;
    [_staffScreenNode addChild:grandStaffButtonNode];
    
    SpriteButton *backButton = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BackButton" stringByAppendingString:_deviceSuffix]]];
    [backButton setDefaults];
    backButton.name = @"BackButton";
    backButton.position = CGPointMake(0.5*backButton.size.width + 0.5*backButton.size.height, backButton.size.height);
    backButton.delegate = self;
    [_staffScreenNode addChild:backButton];
    
}

-(void)killStaff{
    
    [_staffScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionStaffToNotes{
    [self killStaff];
    [self loadNotes];
}

-(void)transitionStaffToKey{
    [self killStaff];
    [self loadKey];
}

#pragma mark - Notes

-(void)loadNotes{
    
    _currentScreen = kNotes;
    
    _notesScreenNode = [SKNode node];
    _notesScreenNode.name = @"NotesScreenNode";
    [self addChild:_notesScreenNode];
    
    
    SpriteButton *singleNotesButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"SingleNotes" stringByAppendingString:_deviceSuffix]]];
    [singleNotesButtonNode setDefaults];
    singleNotesButtonNode.name = @"SingleNotes";
    int spaceBetweenButtons = (self.size.height - 3*singleNotesButtonNode.size.height)/4;
    singleNotesButtonNode.position = CGPointMake(0.5*self.size.width, 3*spaceBetweenButtons + 2.5*singleNotesButtonNode.size.height);
    singleNotesButtonNode.delegate = self;
    [_notesScreenNode addChild:singleNotesButtonNode];
    
    SpriteButton *multipleNotesButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"MultipleNotes" stringByAppendingString:_deviceSuffix]]];
    [multipleNotesButtonNode setDefaults];
    multipleNotesButtonNode.name = @"MultipleNotes";
    multipleNotesButtonNode.position = CGPointMake(0.5*self.size.width, 2*spaceBetweenButtons + 1.5*multipleNotesButtonNode.size.height);
    multipleNotesButtonNode.delegate = self;
    [_notesScreenNode addChild:multipleNotesButtonNode];
    
    SpriteButton *combinationNotesButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"CombinationNotes" stringByAppendingString:_deviceSuffix]]];
    [combinationNotesButtonNode setDefaults];
    combinationNotesButtonNode.name = @"CombinationNotes";
    combinationNotesButtonNode.position = CGPointMake(0.5*self.size.width, 1*spaceBetweenButtons + 0.5*combinationNotesButtonNode.size.height);
    combinationNotesButtonNode.delegate = self;
    [_notesScreenNode addChild:combinationNotesButtonNode];
    
    SpriteButton *backButton = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BackButton" stringByAppendingString:_deviceSuffix]]];
    [backButton setDefaults];
    backButton.name = @"BackButton";
    backButton.position = CGPointMake(0.5*backButton.size.width + 0.5*backButton.size.height, backButton.size.height);
    backButton.delegate = self;
    [_notesScreenNode addChild:backButton];
    
}

-(void)killNotes{
    
    [_notesScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionNotesToLowRange{
    [self killNotes];
    [self loadLowRange];
}

-(void)transitionNotesToStaff{
    [self killNotes];
    [self loadStaff];
}

#pragma mark - Range

-(void)loadLowRange{
    
    _currentScreen = kLowRange;
    
    _lowRangeScreenNode = [SKNode node];
    _lowRangeScreenNode.name = @"LowRangeScreenNode";
    [self addChild:_lowRangeScreenNode];
    
    SKColor *textColor =[UIColor whiteColor];
    SKLabelNode *lowRangeLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    lowRangeLabelNode.name = @"LowRange";
    lowRangeLabelNode.fontSize = 0.07*self.size.height;
    lowRangeLabelNode.fontColor =textColor;
    lowRangeLabelNode.text = @"Play Lowest Note";
    lowRangeLabelNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [_lowRangeScreenNode addChild:lowRangeLabelNode];
    
    SpriteButton *backButton = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BackButton" stringByAppendingString:_deviceSuffix]]];
    [backButton setDefaults];
    backButton.name = @"BackButton";
    backButton.position = CGPointMake(0.5*backButton.size.width + 0.5*backButton.size.height, backButton.size.height);
    backButton.delegate = self;
    [_lowRangeScreenNode addChild:backButton];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeAlphaTo:0.5 duration:1.0],
                                           [SKAction fadeAlphaTo:1.0 duration:0.5]]];
    
                       
    [lowRangeLabelNode runAction:[SKAction repeatActionForever:blink]];
     

}

-(void)killLowRange{
    
    [_lowRangeScreenNode removeAllChildren];
    [self removeAllChildren];
    

}

-(void)transitionLowRangeToHighRange{
    [self killLowRange];
    [self loadHighRange];
}

-(void)transitionLowRangeToNotes{
    [self killLowRange];
    [self loadNotes];
}

-(void)loadHighRange{
    
    _currentScreen = kHighRange;
    
    _highRangeScreenNode = [SKNode node];
    _highRangeScreenNode.name = @"HighRangeScreenNode";
    [self addChild:_highRangeScreenNode];
    
    SKLabelNode *highRangeLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    highRangeLabelNode.name = @"HighRange";
    highRangeLabelNode.fontSize = 0.07*self.size.height;
    highRangeLabelNode.fontColor = [UIColor whiteColor];
    highRangeLabelNode.text = @"Play Highest Note";
    highRangeLabelNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [_highRangeScreenNode addChild:highRangeLabelNode];
    
    SpriteButton *backButton = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BackButton" stringByAppendingString:_deviceSuffix]]];
    [backButton setDefaults];
    backButton.name = @"BackButton";
    backButton.position = CGPointMake(0.5*backButton.size.width + 0.5*backButton.size.height, backButton.size.height);
    backButton.delegate = self;
    [_highRangeScreenNode addChild:backButton];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeAlphaTo:0.5 duration:1.0],
                                           [SKAction fadeAlphaTo:1.0 duration:0.5]]];
    
    
    [highRangeLabelNode runAction:[SKAction repeatActionForever:blink]];
}

-(void)killHighRange{
    [_highRangeScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionHighRangeToGame{
    [self killHighRange];
    [self buildChordCatalog];
    [self loadGame];
}

-(void)transitionHighRangeToLowRange{
    [self killHighRange];
    [self loadLowRange];
}

#pragma mark - Game

-(void)loadGame{
    
    _currentScreen = kGame;
    _timeRemaining = 60;
    _score = 0;
    
    [_notePressedFlags removeAllObjects];
    
    self.backgroundColor = [UIColor whiteColor];
    
    _gameScreenNode = [SKNode node];
    _gameScreenNode.name = @"GameScreenNode";
    [self addChild:_gameScreenNode];
    
    _pausedScreenNode = [SKNode node];
    _pausedScreenNode.name = @"PausedScreenNode";
    [self addChild:_pausedScreenNode];
    
    if (_gameData.staff == 0) {
        
        SKSpriteNode *bassClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BassClef" stringByAppendingString:_deviceSuffix]]];
        bassClef.name = @"BassClef";
        bassClef.xScale = 0.5;
        bassClef.yScale = 0.5;
        bassClef.position = CGPointMake(0.1*self.size.width, 14.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
        [_gameScreenNode addChild:bassClef];
        
        for (int i=12; i<=16; i++) {
            [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, i*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        
    }
    else if (_gameData.staff == 1){
        SKSpriteNode *trebleClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"TrebleClef" stringByAppendingString:_deviceSuffix]]];
        trebleClef.name = @"TrebleClef";
        trebleClef.xScale = 0.5;
        trebleClef.yScale = 0.5;
        trebleClef.position = CGPointMake(0.1*self.size.width, 14*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
        [_gameScreenNode addChild:trebleClef];
        
        for (int i=12; i<=16; i++) {
            [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, i*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        
    }
    else if (_gameData.staff == 2){
        
        SKSpriteNode *bassClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BassClef" stringByAppendingString:_deviceSuffix]]];
        bassClef.name = @"BassClef";
        bassClef.xScale = 0.5;
        bassClef.yScale = 0.5;
        bassClef.position = CGPointMake(0.1*self.size.width, 9.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
        [_gameScreenNode addChild:bassClef];
        
        SKSpriteNode *trebleClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"TrebleClef" stringByAppendingString:_deviceSuffix]]];
        trebleClef.name = @"TrebleClef";
        trebleClef.xScale = 0.5;
        trebleClef.yScale = 0.5;
        trebleClef.position = CGPointMake(0.1*self.size.width, 23*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
        [_gameScreenNode addChild:trebleClef];
        
        
        for (int i=7; i<=11; i++) {
            [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, i*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        for (int i=21; i<=25; i++) {
            [self loadStaffLineWithPosition:CGPointMake(0.5*self.size.width, i*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
    }
    
    [self loadKeySignature];

    
    
    
    
    _currentNameNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _currentNameNode.name = @"NoteName";
    _currentNameNode.fontSize = 0.05*self.size.height;
    _currentNameNode.fontColor = [UIColor blackColor];
    _currentNameNode.position = CGPointMake(0.95*self.size.width, 0.05*self.size.height);
    _currentNameNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [_gameScreenNode addChild:_currentNameNode];
   
    _timeRemainingNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _timeRemainingNode.name = @"TimeRemaining";
    _timeRemainingNode.fontSize = 0.05*self.size.height;
    _timeRemainingNode.fontColor = [UIColor blackColor];
    _timeRemainingNode.position = CGPointMake(0.95*self.size.width, 0.9*self.size.height);
    _timeRemainingNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _timeRemainingNode.text = [NSString stringWithFormat:@":%i",_timeRemaining];
    [_gameScreenNode addChild:_timeRemainingNode];
    
    _scoreNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _scoreNode.name = @"Score";
    _scoreNode.fontSize = 0.05*self.size.height;
    _scoreNode.fontColor = [UIColor blackColor];
    _scoreNode.position = CGPointMake(0.05*self.size.width, 0.9*self.size.height);
    _scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreNode.text = [NSString stringWithFormat:@"%i",_score];
    [_gameScreenNode addChild:_scoreNode];
    
    SpriteButton *pauseButton = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"PauseButton" stringByAppendingString:_deviceSuffix]]];
    [pauseButton setDefaults];
    pauseButton.name = @"PauseButton";
    pauseButton.position = CGPointMake(0.5*pauseButton.size.width + 0.5*pauseButton.size.height, pauseButton.size.height);
    pauseButton.delegate = self;
    [_gameScreenNode addChild:pauseButton];
    
    id wait = [SKAction waitForDuration:1];
    id run = [SKAction runBlock:^{
        [self decrementTimeRemaining];
    }];
    [_gameScreenNode runAction:[SKAction repeatAction:[SKAction sequence:@[wait, run]] count:_timeRemaining]];
    
    
    //Generate random chord
    [self loadNotesFromChord:_chordCatalog[arc4random_uniform((int)_chordCatalog.count - 1)]];
}

-(void)loadPausedMode{
    
    
    [_gameScreenNode enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
         node.hidden = YES;
    }];
    [_gameScreenNode enumerateChildNodesWithName:@"LedgerLine" usingBlock:^(SKNode *node, BOOL *stop){
         node.hidden = YES;
    }];
    [_gameScreenNode enumerateChildNodesWithName:@"Accidental" usingBlock:^(SKNode *node, BOOL *stop){
        node.hidden = YES;
    }];
    
    
    
    [self enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    
    SpriteButton *retryButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"RetryButton" stringByAppendingString:_deviceSuffix]]];
    [retryButtonNode setDefaults];
    retryButtonNode.name = @"RetryButton";
    int spaceBetweenButtons = 0.75*retryButtonNode.size.height;
    retryButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height + spaceBetweenButtons);
    retryButtonNode.delegate = self;
    [_pausedScreenNode addChild:retryButtonNode];
    
    SpriteButton *returnButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"ReturnButton" stringByAppendingString:_deviceSuffix]]];
    [returnButtonNode setDefaults];
    returnButtonNode.name = @"ReturnButton";
    returnButtonNode.position = CGPointMake(0.5*self.size.width,  0.5*self.size.height - spaceBetweenButtons);
    returnButtonNode.delegate = self;
    [_pausedScreenNode addChild:returnButtonNode];
}



-(void)killPausedMode{
    [_pausedScreenNode removeAllChildren];
    
    
    [_gameScreenNode enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        node.hidden = NO;
    }];
    [_gameScreenNode enumerateChildNodesWithName:@"LedgerLine" usingBlock:^(SKNode *node, BOOL *stop){
        node.hidden = NO;
    }];
    [_gameScreenNode enumerateChildNodesWithName:@"Accidental" usingBlock:^(SKNode *node, BOOL *stop){
        node.hidden = NO;
    }];
    
}

-(void)loadKeySignature{
    
    double keySignatureSymbolSpacing = 0.02;
    
    //Add key signature symbols
    if (_gameData.key <= -1 && _gameData.key < 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake(0.2*self.size.width, 13*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake(0.2*self.size.width, 14*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake(0.2*self.size.width, 8*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake(0.2*self.size.width, 23*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key <= -2 && _gameData.key <0){
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 14.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 15.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 9.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 24.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key <= -3 && _gameData.key <0){
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 12.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 13.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 7.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 22.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key <= -4 && _gameData.key <0){
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 14*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 15*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 9*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 24*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key <= -5 && _gameData.key <0){
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 12*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 13*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 7*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 22*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key <= -6 && _gameData.key <0){
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 13.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 14.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 8.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 23.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key <= -7 && _gameData.key <0){
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 11.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 12.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 6.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:-1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 21.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key >= 1 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake(0.2*self.size.width, 15*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake(0.2*self.size.width, 16*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake(0.2*self.size.width, 10*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake(0.2*self.size.width, 25*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key >= 2 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 13.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 14.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 8.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 1.0*keySignatureSymbolSpacing)*self.size.width, 23.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key >= 3 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 15.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 16.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 10.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 2.0*keySignatureSymbolSpacing)*self.size.width, 25.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key >= 4 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 14*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 15*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 9*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 3.0*keySignatureSymbolSpacing)*self.size.width, 24*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key >= 5 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 12.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 13.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 7.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 4.0*keySignatureSymbolSpacing)*self.size.width, 22.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    
    if (_gameData.key >= 6 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 14.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 15.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 9.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 5.0*keySignatureSymbolSpacing)*self.size.width, 24.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
    if (_gameData.key >= 7 && _gameData.key > 0) {
        
        
        if (_gameData.staff == 0) {
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 13*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        }
        else if (_gameData.staff == 1){
            
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 14*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
        else if (_gameData.staff == 2){
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 8*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            [self addKeySignatureSymbol:1 WithPosition:CGPointMake((0.2 + 6.0*keySignatureSymbolSpacing)*self.size.width, 23*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
            
        }
    }
}

-(void)addKeySignatureSymbol:(int)symbol WithPosition:(CGPoint)position{
    
    CGPoint accidentalAnchor;
    NSString *symbolName;
    
    if (symbol == -1) {
        symbolName = @"Flat";
        accidentalAnchor = CGPointMake(0.5, 0.3);
        
    }
    else if (symbol == 1){
        symbolName = @"Sharp";
        accidentalAnchor = CGPointMake(0.5, 0.5);
    }
    else{
        symbolName = @"Natural";
        accidentalAnchor = CGPointMake(0.5, 0.5);
        NSLog(@"Error determining key signature");
    }
    
    SKSpriteNode *keySignatureSymbol = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[symbolName stringByAppendingString:_deviceSuffix]]];
    keySignatureSymbol.name = @"KeySignature";
    keySignatureSymbol.xScale = 0.35;
    keySignatureSymbol.yScale = 0.35;
    keySignatureSymbol.anchorPoint = accidentalAnchor;
    //Determine y position based on staff
    keySignatureSymbol.position = position;
    [_gameScreenNode addChild:keySignatureSymbol];
    
}
-(void)killGame{
  
    [_gameScreenNode removeAllChildren];
    [_pausedScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionGameToScore{
    [self killGame];
    [self loadScore];
}

-(void)transitionGameToGame{
    [self killPausedMode];
    [self killGame];
    [self loadGame];
}

-(void)transitionGameToMenu{
    [self killPausedMode];
    [self killGame];
    [self loadMenu];
}

-(void)decrementTimeRemaining{
    _timeRemaining--;
    _timeRemainingNode.text = [NSString stringWithFormat:@":%i",_timeRemaining];
}

-(void)removeGameNotes{
    [_gameScreenNode enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [_gameScreenNode enumerateChildNodesWithName:@"LedgerLine" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    [_gameScreenNode enumerateChildNodesWithName:@"Accidental" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

#pragma mark - Score

-(void)loadScore{
    
    _currentScreen = kScore;
    self.backgroundColor = [UIColor darkGrayColor];
    
    if (_score > _gameData.bestScore) {
        _gameData.bestScore = _score;
        [_userDefaults setInteger:_score forKey:@"BestScore"];
    }
    
    _scoreScreenNode = [SKNode node];
    _scoreScreenNode.name = @"ScoreScreenNode";
    [self addChild:_scoreScreenNode];
    
    SKLabelNode *gameOverLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    gameOverLabelNode.name = @"GameOver";
    gameOverLabelNode.fontSize = 0.1*self.size.height;
    gameOverLabelNode.fontColor = [UIColor whiteColor];
    gameOverLabelNode.text = @"Game Over";
    gameOverLabelNode.position = CGPointMake(0.5*self.size.width, 0.85*self.size.height);
    [_scoreScreenNode addChild:gameOverLabelNode];
    
    SKSpriteNode *scoreBannerNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"ScoreBanner" stringByAppendingString:_deviceSuffix]]];
    scoreBannerNode.name = @"ScoreBanner";
    scoreBannerNode.xScale = 0.5;
    scoreBannerNode.yScale = 0.5;
    scoreBannerNode.position = CGPointMake(0.5*self.size.width, 0.7*self.size.height);
    [_scoreScreenNode addChild:scoreBannerNode];
    
    SKLabelNode *scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    scoreLabelNode.name = @"Score";
    scoreLabelNode.fontSize = 0.8*scoreBannerNode.size.height;
    scoreLabelNode.fontColor = [SKColor whiteColor];
    scoreLabelNode.text = [NSString stringWithFormat:@"Score: %i",_score];
    scoreLabelNode.position =CGPointMake(0.5*self.size.width, scoreBannerNode.position.y- 0.4*scoreLabelNode.fontSize);
    [_scoreScreenNode addChild:scoreLabelNode];
    
    
    SKSpriteNode *bestBannerNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BestBanner" stringByAppendingString:_deviceSuffix]]];
    bestBannerNode.name = @"BestBanner";
    bestBannerNode.xScale = 0.5;
    bestBannerNode.yScale = 0.5;
    bestBannerNode.position = CGPointMake(0.5*self.size.width, scoreBannerNode.position.y - 0.5*scoreBannerNode.size.height - 0.5*bestBannerNode.size.height);
    [_scoreScreenNode addChild:bestBannerNode];
    
    SKLabelNode *bestLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    bestLabelNode.name = @"Best";
    bestLabelNode.fontSize = 0.8*bestBannerNode.size.height;
    bestLabelNode.fontColor = [SKColor whiteColor];
    bestLabelNode.text = [NSString stringWithFormat:@"Best: %i",_gameData.bestScore];
    bestLabelNode.position =CGPointMake(0.5*self.size.width, bestBannerNode.position.y- 0.4*bestLabelNode.fontSize);
    [_scoreScreenNode addChild:bestLabelNode];
    
    SpriteButton *retryButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"RetryButton" stringByAppendingString:_deviceSuffix]]];
    [retryButtonNode setDefaults];
    retryButtonNode.name = @"RetryButton";
    int buttonSectionHeight = (bestBannerNode.position.y - 0.5*bestBannerNode.size.height);
    int spaceBetweenButtons = (buttonSectionHeight - 2*retryButtonNode.size.height)/3;
    retryButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*buttonSectionHeight + 0.5*spaceBetweenButtons + 0.5*retryButtonNode.size.height);
    retryButtonNode.delegate = self;
    [_scoreScreenNode addChild:retryButtonNode];
    
    SpriteButton *returnButtonNode = [SpriteButton spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"ReturnButton" stringByAppendingString:_deviceSuffix]]];
    [returnButtonNode setDefaults];
    returnButtonNode.name = @"ReturnButton";
    returnButtonNode.position = CGPointMake(0.5*self.size.width, spaceBetweenButtons + 0.5*returnButtonNode.size.height);
    returnButtonNode.delegate = self;
    [_scoreScreenNode addChild:returnButtonNode];
    
    
}


-(void)killScore{
    
    [_scoreScreenNode removeAllChildren];
    [self removeAllChildren];
}

-(void)transitionScoreToGame{
    [self killScore];
    [self loadGame];
}

-(void)transitionScoreToMenu{
    [self killScore];
    [self loadMenu];
}

#pragma mark - Chord Parsing

-(void)buildChordCatalog{
    NSArray *chordArray;
    chordArray = [self chordsFromJSON];
    _chordCatalog = [self chordCatalogFromChordArray:chordArray];
    
}

-(NSArray*)chordsFromJSON{
    
    NSString *query;
    if (_gameData.staff == 2) {
        query = [NSString stringWithFormat:@"key == %i", _gameData.key];
    }
    else{
        query = [NSString stringWithFormat:@"key == %i AND staff == %i", _gameData.key, _gameData.staff];
    }
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chord"
                                              inManagedObjectContext:context];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:query]];
    
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    
    return fetchedObjects;
    
}

-(NSArray*)arrayFromPropertyList:(NSString*)list{
    
    return [NSArray arrayWithContentsOfFile:list];
    
}

-(bool)chordInBounds:(Chord*)chord{
    NSSet *notes = chord.notes;
    bool inBounds = NO;
    for (Note *note in notes) {
        if ([note midiNumber] < _gameData.lowRange) {
            inBounds = NO;
            break;
        }
        else if([note midiNumber] > _gameData.highRange) {
            inBounds = NO;
            break;
        }
        else{
            inBounds = YES;
        }
    }
    return inBounds;
}

-(NSArray *)chordCatalogFromChordArray:(NSArray*)chordArray{
    
    NSMutableArray *chordCatalog = [NSMutableArray arrayWithArray:chordArray];
   
    for (Chord *chord in chordCatalog) {
        
        if (![self chordInBounds:chord]) {
            [chordCatalog removeObject:chord];
        }
        
    }
    
    return chordCatalog;
}

-(void)loadStaffLineWithPosition:(CGPoint)position{
    SKSpriteNode *staffLine = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"StaffLine" stringByAppendingString:_deviceSuffix]]];
    staffLine.name = @"StaffLine";
    staffLine.xScale = 0.5;
    staffLine.yScale = 0.5;
    staffLine.position = position;
    [_gameScreenNode addChild:staffLine];
    
}

-(void)loadLedgerLineWithPosition:(CGPoint)position{
    SKSpriteNode *ledgerLineNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"LedgerLine" stringByAppendingString:_deviceSuffix]]];
    ledgerLineNode.name = @"LedgerLine";
    ledgerLineNode.xScale = 0.5;
    ledgerLineNode.yScale = 0.5;
    ledgerLineNode.position = position;
    [_gameScreenNode addChild:ledgerLineNode];
}

-(void)loadNotesFromChord:(Chord*)chord{
    
    
    NSSet *notes = chord.notes;
    
    _currentNotes = notes;
    _currentName = chord.name;
    _currentNameNode.text = _currentName;
    
    
    
    [self addLedgerLinesForChord:chord];
    for (Note *note in notes) {
        
        [self addNote:note fromChord:chord];
        if ([note.accidental intValue] == 1) {
            [self addAccidentalForNote:note fromChord:chord];
        }
    }
    
    
}

-(void)addNote:(Note*)note fromChord:(Chord*)chord{
    
    NSLog(@"Chord: %@, Note: %@:%i", chord.name, note.name, [note staffLocation] );
    //Determine y position based on staff
    int yPosition = [self noteYPositionFromStaffLocation:[note staffLocation] forStaff:[note.staff intValue]];
    
    //Determine x position based on whether the note is shifted to prevent overlap
    int xPosition;
    if(![chord noteOverlapForNote:note]){
        xPosition = 0.5*self.size.width;
    }
    else{
        xPosition = 0.56*self.size.width;
    }
    
    NSMutableDictionary *noteData;
    noteData = [[NSMutableDictionary alloc]init];
    [noteData setValue:[NSNumber numberWithInt:note.midiNumber] forKey:@"MidiNumber"];
    //Create Note node
    SKSpriteNode *noteNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"Note" stringByAppendingString:_deviceSuffix]]];
    noteNode.name = @"Note";
    noteNode.xScale = 0.5;
    noteNode.yScale = 0.5;
    noteNode.color = [UIColor blackColor];
    noteNode.colorBlendFactor = 1;
    noteNode.userData = noteData;
    noteNode.position = CGPointMake(xPosition, yPosition);
    [_gameScreenNode addChild:noteNode];
    
}

/*Determines the Y-Position for a note based on the staff
 location number */
-(int)noteYPositionFromStaffLocation:(int)staffLocation forStaff:(int)staff
{
    if (_gameData.staff == 0) {
        return 0.5*(staffLocation + 10)*self.size.height/(NUMBER_OF_STAFF_LINES + 1) + 0.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1);
    }
    else if (_gameData.staff == 1){
       return 0.5*(staffLocation - 2)*self.size.height/(NUMBER_OF_STAFF_LINES + 1) + 0.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1);
    }
    else if (_gameData.staff == 2) {
        //Position nodes relative to bass staff
        if (staff == 0) {
            return 0.5*staffLocation*self.size.height/(NUMBER_OF_STAFF_LINES + 1) + 0.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1);
        }
        //Position nodes relative to treble staff
        else if(staff == 1)
        {
            return 0.5*(staffLocation + 16)*self.size.height/(NUMBER_OF_STAFF_LINES + 1) + 0.5*self.size.height/(NUMBER_OF_STAFF_LINES + 1);
        }
        else{
            NSLog(@"Error: Failed to determine staff location");
            return 0;
        }

    }
    else{
        NSLog(@"Error: Failed to determine staff location");
        return 0;
    }
    
}

-(void)addAccidentalForNote:(Note*)note fromChord:(Chord*)chord{

    
    //Add accidental symbol to note

    NSString *accidental;
    CGPoint accidentalAnchor;

    switch ([note.intonation intValue]) {
        case -2:
            accidental = @"DoubleFlat";
            accidentalAnchor = CGPointMake(0.5, 0.3);
            break;
        case -1:
            accidental = @"Flat";
            accidentalAnchor = CGPointMake(0.5, 0.3);
            break;
        case 0:
            accidental = @"Natural";
            accidentalAnchor = CGPointMake(0.5, 0.5);
            break;
        case 1:
            accidental = @"Sharp";
            accidentalAnchor = CGPointMake(0.5, 0.5);
            break;
        case 2:
            accidental = @"DoubleSharp";
            accidentalAnchor = CGPointMake(0.5, 0.5);
            break;
        default:
            accidental = @"Natural";
            accidentalAnchor = CGPointMake(0.5, 0.5);
            NSLog(@"Error: Accidental symbol not found");
            break;
    }
 
    //Create Accidental node
    SKSpriteNode *accidentalNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[accidental stringByAppendingString:_deviceSuffix]]];
    accidentalNode.name = @"Accidental";
    accidentalNode.xScale = 0.35;
    accidentalNode.yScale = 0.35;
    accidentalNode.anchorPoint = accidentalAnchor;
    
    //Determine y position based on staff
    int yPosition = [self noteYPositionFromStaffLocation:[note staffLocation] forStaff:[note.staff intValue]];
    
    int xPosition;
    if(![chord accidentalOverlapForNote:note]){
        xPosition = 0.5*self.size.width - 0.1*self.size.width;
    }
    else{
        xPosition = 0.5*self.size.width - 0.15*self.size.width;
    }
    
    accidentalNode.position = CGPointMake(xPosition, yPosition);
    [_gameScreenNode addChild:accidentalNode];
}

-(void)addLedgerLinesForChord:(Chord*)chord{

    int currentLedgerLine = 0;
    //Add ledger lines for notes below bass clef
    if (_gameData.staff == 0) currentLedgerLine = 12;
    else if (_gameData.staff == 2) currentLedgerLine = 7;
    for (int j = 0; j < [chord centeredLedgerLinesBelowBassClef]/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.5*self.size.width, (currentLedgerLine - 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine--;
    }
    
    if (_gameData.staff == 0) currentLedgerLine = 12;
    else if (_gameData.staff == 2) currentLedgerLine = 7;
    for (int j = 0; j < [chord shiftedLedgerLinesBelowBassClef]/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.56*self.size.width, (currentLedgerLine - 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine--;
    }
    
    //Add ledger lines for notes above bass clef
    if (_gameData.staff == 0) currentLedgerLine = 16;
    else if (_gameData.staff == 2) currentLedgerLine = 11;
    for (int j = 0; j < ([chord centeredLedgerLinesAboveBassClef])/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.5*self.size.width, (currentLedgerLine + 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine++;
    }
    
    if (_gameData.staff == 0) currentLedgerLine = 16;
    else if (_gameData.staff == 2) currentLedgerLine = 11;
    for (int j = 0; j < ([chord shiftedLedgerLinesAboveBassClef])/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.56*self.size.width, (currentLedgerLine + 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine++;
    }
    
    //Add ledger lines for notes below treble clef
    if (_gameData.staff == 1) currentLedgerLine = 12;
    else if (_gameData.staff == 2) currentLedgerLine = 21;
    for (int j = 0; j < ([chord centeredLedgerLinesBelowTrebleClef])/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.5*self.size.width, (currentLedgerLine - 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine--;
    }
    if (_gameData.staff == 1) currentLedgerLine = 12;
    else if (_gameData.staff == 2) currentLedgerLine = 21;
    for (int j = 0; j < ([chord shiftedLedgerLinesBelowTrebleClef])/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.56*self.size.width, (currentLedgerLine - 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine--;
    }
    
    //Add ledger lines for notes above treble clef
    if (_gameData.staff == 1) currentLedgerLine = 16;
    else if (_gameData.staff == 2) currentLedgerLine = 25;
    for (int j = 0; j < ([chord centeredLedgerLinesAboveTrebleClef])/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.5*self.size.width, (currentLedgerLine + 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine++;
    }
    
    if (_gameData.staff == 1) currentLedgerLine = 16;
    else if (_gameData.staff == 2) currentLedgerLine = 25;
    for (int j = 0; j < ([chord shiftedLedgerLinesAboveTrebleClef])/2; j++) {
        [self loadLedgerLineWithPosition:CGPointMake(0.56*self.size.width, (currentLedgerLine + 1)*self.size.height/(NUMBER_OF_STAFF_LINES + 1))];
        currentLedgerLine++;
    }
}

#pragma mark - MIDI Handling

-(void)handlePacketList:(const MIDIPacketList*)midiPacketList{
    
    
    
    //Set the Lowest Note the game will display
    if (_currentScreen == kLowRange) {
        if([MIDIUtility getMessageType:midiPacketList] == 0x90)
        {
            _gameData.lowRange = [MIDIUtility getNoteNumber:midiPacketList];
            [self transitionLowRangeToHighRange];
        }
    }
    //Set the Highest Note the game will display
    else if(_currentScreen == kHighRange) {
        if([MIDIUtility getMessageType:midiPacketList] == 0x90){
            _gameData.highRange = [MIDIUtility getNoteNumber:midiPacketList];
            [self transitionHighRangeToGame];
        }
    }
    //Check if note on or note off and call appropriate method
    else if (_currentScreen == kGame) {
        if([MIDIUtility getMessageType:midiPacketList] == 0x90)
            [self checkNoteHitWithNumber:[MIDIUtility getNoteNumber:midiPacketList]];
        else if ([MIDIUtility getMessageType:midiPacketList] == 0x80)
            [self checkNoteReleaseWithNumber:[MIDIUtility getNoteNumber:midiPacketList]];
    }
    
}

-(void)checkNoteHitWithNumber:(int)userKeyNumber
{
    
    [_notePressedFlags addObject: [NSNumber numberWithInt:userKeyNumber]];
    
    
    bool correctPlay = NO;
    
    for (Note * note in _currentNotes) {
        correctPlay = NO;
        for (int j = 0; j < (int)_notePressedFlags.count; j++) {
            if ([note midiNumber] == [_notePressedFlags[j] intValue]) {
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
    
    [_gameScreenNode enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        SKSpriteNode *noteNode = (SKSpriteNode*)node;
        
        if ([[noteNode.userData valueForKey:@"MidiNumber"] intValue] == userKeyNumber)  {
            noteNode.color = [SKColor greenColor];
        }
    }];
    
    if (correctPlay) {
       
        [self removeGameNotes];
        _score = _score + 25*(int)_currentNotes.count;
        [self loadNotesFromChord:_chordCatalog[arc4random_uniform((int)_chordCatalog.count - 1)]];
        
        _scoreNode.text = [NSString stringWithFormat:@"%i",_score];
    }
    
    
    
}



-(void)checkNoteReleaseWithNumber:(int)userKeyNumber
{
    [_gameScreenNode enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        SKSpriteNode *noteNode = (SKSpriteNode*)node;
        
        if ([[noteNode.userData valueForKey:@"MidiNumber"] intValue] == userKeyNumber)  {
            noteNode.color = [SKColor blackColor];
        }
    }];
    
    [_notePressedFlags removeObjectIdenticalTo:[NSNumber numberWithInt:userKeyNumber]];
}

/* This function is repsonsible for processing all SpriteButtons and calling the correct screen
transtion functions */

-(void)transition:(NSString *)name{
    if (_currentScreen == kMenu) {
        if ([name isEqualToString:@"PlayButton"]) {
            [self transitionMenuToKey];
        }
    }
    
    if (_currentScreen == kKey) {
        if ([name isEqualToString:@"CFlatMajor"]) {
            _gameData.key = -7;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"GFlatMajor"]) {
            _gameData.key = -6;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"DFlatMajor"]) {
            _gameData.key = -5;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"AFlatMajor"]) {
            _gameData.key = -4;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"EFlatMajor"]) {
            _gameData.key = -3;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"BFlatMajor"]) {
            _gameData.key = -2;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"FMajor"]) {
            _gameData.key = -1;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"CMajor"]) {
            _gameData.key = 0;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"GMajor"]) {
            _gameData.key = 1;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"DMajor"]) {
            _gameData.key = 2;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"AMajor"]) {
            _gameData.key = 3;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"EMajor"]) {
            _gameData.key = 4;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"BMajor"]) {
            _gameData.key = 5;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"FSharpMajor"]) {
            _gameData.key = 6;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"CSharpMajor"]) {
            _gameData.key = 7;
            [self transitionKeyToStaff];
        }
        else if ([name isEqualToString:@"BackButton"]){
            [self transitionKeyToMenu];
        }
        
    }
    
    if (_currentScreen == kStaff) {
        if ([name isEqualToString:@"BassStaff"]) {
            _gameData.staff = 0;
            [self transitionStaffToNotes];
        }
        else if ([name isEqualToString:@"TrebleStaff"]) {
            _gameData.staff = 1;
            [self transitionStaffToNotes];
        }
        else if ([name isEqualToString:@"GrandStaff"]) {
            _gameData.staff = 2;
            [self transitionStaffToNotes];
        }
        else if ([name isEqualToString:@"BackButton"]){
            [self transitionStaffToKey];
        }
    }
    if (_currentScreen == kNotes) {
        if ([name isEqualToString:@"SingleNotes"]) {
            _gameData.notes = 0;
            [self transitionNotesToLowRange];
        }
        else if ([name isEqualToString:@"MultipleNotes"]) {
            _gameData.notes = 1;
            [self transitionNotesToLowRange];
        }
        else if ([name isEqualToString:@"CombinationNotes"]) {
            _gameData.notes = 2;
            [self transitionNotesToLowRange];
        }
        else if ([name isEqualToString:@"BackButton"]){
            [self transitionNotesToStaff];
        }
    }
    if(_currentScreen == kLowRange){
        if ([name isEqualToString:@"BackButton"]){
            [self transitionLowRangeToNotes];
        }
    }
    if(_currentScreen == kHighRange){
        if ([name isEqualToString:@"BackButton"]){
            [self transitionHighRangeToLowRange];
        }
    }
    if(_currentScreen == kGame){
        if ([name isEqualToString:@"PauseButton"]){
            if (_gameData.isPaused == NO) {
                [self loadPausedMode];
                _gameScreenNode.paused = YES;
                _gameData.isPaused = YES;
                
                
            }
            else if (_gameData.isPaused == YES) {
                _gameScreenNode.paused = NO;
                _gameData.isPaused = NO;
                [_gameScreenNode enumerateChildNodesWithName:@"PauseButton" usingBlock:^(SKNode *node, BOOL *stop){
                    node.alpha = 1.0;
                }];
                [self killPausedMode];
            }
        }
        else if ([name isEqualToString:@"RetryButton"]) {
            _gameData.isPaused = NO;
            [self transitionGameToGame];
        }
        else if ([name isEqualToString:@"ReturnButton"]) {
            _gameData.isPaused = NO;
            [self transitionGameToMenu];
        }
    }
    if (_currentScreen == kScore) {
        if ([name isEqualToString:@"RetryButton"]) {
            [self transitionScoreToGame];
        }
        else if ([name isEqualToString:@"ReturnButton"]) {
            [self transitionScoreToMenu];
            
        }
    }
    
    
}

@end
