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

@implementation GameScene

const int NUMBER_OF_STAFF_LINES = 34;

static GameScene *_gameScene;

int _device;
NSString *_deviceSuffix;
GameData *_gameData;
NSArray *_chordCatalog;
AudioController *audioController;

enum currentScreen {kNothing = 0,
                    kMenu = 1,
                    kKey = 2,
                    kStaff = 3,
                    kNotes = 4,
                    kLowRange = 5,
                    kHighRange = 6,
                    kGame = 7,
                    kScore = 8};

SKNode *_menuScreenNode;
SKNode *_keyScreenNode;
SKNode *_staffScreenNode;
SKNode *_notesScreenNode;
SKNode *_lowRangeScreenNode;
SKNode *_highRangeScreenNode;
SKNode *_gameScreenNode;
SKNode *_scoreScreenNode;

enum currentScreen _currentScreen;

int _midiDeviceIndex;
SKLabelNode *_midiDeviceName;

//Game
NSMutableArray *_notePressedFlags;
NSMutableArray *_fifoMidiEvents;
NSArray *_currentNotes;

SKLabelNode *_currentNameNode;
SKLabelNode *_timeRemainingNode;
SKLabelNode *_scoreNode;

NSString *_currentName;
int _timeRemaining;
int _score;




static inline CGPoint rotatedPosition(CGPoint startPosition, float distance, float radians){
    
    float xPosition = startPosition.x + distance*cosf(radians + M_PI/2);
    float yPosition = startPosition.y + distance*sinf(radians + M_PI/2);
    
    return CGPointMake(xPosition, yPosition);
    
}

void midiInputCallback (const MIDIPacketList *list,
                        void *procRef,
                        void *srcRef)
{
    [_gameScene handlePacketList:list];
    [MIDIUtility processMessage:list];
}

-(void)didMoveToView:(SKView *)view {
   
    _currentScreen = kNothing;
    
    _gameScene = self;
    audioController = [[AudioController alloc] init];
    
    _gameData = [[GameData alloc]init];
    _device = [self device];
    _deviceSuffix = [self deviceSuffix:_device];
   
    self.backgroundColor = [UIColor darkGrayColor];
    [self loadMenu];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    if ([node.name isEqualToString:@"PlayButton"]) {
        if (((SpriteButton*)node).selected == YES) {
            [self transitionMenuToKey];
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
    
    //write code for -- dont monitor if not on particular page
    if (_currentScreen == kGame) {
        
        if (_timeRemaining == 0) {
            [self transitionGameToScore];
        }
        
    }
}



#pragma mark - Menu

-(void)loadMenu{
    
    _currentScreen = kMenu;
    
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
    SpriteButton *bottomPanelNode = [SpriteButton spriteNodeWithTexture:bottomPanelTexture];
    [bottomPanelNode setDefaults];
    bottomPanelNode.name = @"BottomPanel";
    bottomPanelNode.position = CGPointMake(0.5*self.size.width, 0.5*bottomPanelNode.size.height);
    bottomPanelNode.delegate = self;
    [_menuScreenNode addChild:bottomPanelNode];
    
    SKLabelNode *titleLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    titleLabelNode.Name = @"TitleLabel";
    titleLabelNode.fontSize = 0.1*self.size.height;
    titleLabelNode.fontColor = [UIColor colorWithHue:212.0/360.0 saturation:67.0/100.0 brightness:89.0/100.0 alpha:1.0];
    titleLabelNode.text = @"Staff Master";
    titleLabelNode.position = CGPointMake(0.5*self.size.width, 0.8*self.size.height);
    [_menuScreenNode addChild:titleLabelNode];
    

    _midiDeviceName = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _midiDeviceName.name = @"MidiDeviceNameLabel";
    _midiDeviceName.fontSize = 0.5*bottomPanelNode.size.height;
    _midiDeviceName.position = CGPointMake(0.5*self.size.width, 0.5*bottomPanelNode.size.height - 0.4*_midiDeviceName.fontSize);
    _midiDeviceName.text = _gameData.selectedDevice.name;
    [_menuScreenNode addChild:_midiDeviceName];
    
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
    
    [self enumerateChildNodesWithName:@"MenuScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"MenuScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
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
    
    //This node is a button that switches major key to minor key
    NSString *majorButtonImageName = @"Major";
    majorButtonImageName = [majorButtonImageName stringByAppendingString:_deviceSuffix];
    SKTexture *majorButtonTexture = [SKTexture textureWithImageNamed:majorButtonImageName];
    SpriteButton *majorButtonNode = [SpriteButton spriteNodeWithTexture:majorButtonTexture];
    [majorButtonNode setDefaults];
    majorButtonNode.name = @"MajorButton";
    majorButtonNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    majorButtonNode.delegate = self;
    [_keyScreenNode addChild:majorButtonNode];
    
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
    
    [self enumerateChildNodesWithName:@"KeyScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"KeyScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)transitionKeyToStaff{
    [self killKey];
    [self loadStaff];
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
    
}

-(void)killStaff{
    [self enumerateChildNodesWithName:@"StaffScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"StaffScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)transitionStaffToNotes{
    [self killStaff];
    [self loadNotes];
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
    
}

-(void)killNotes{
    
    [self enumerateChildNodesWithName:@"NotesScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"NotesScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}

-(void)transitionNotesToLowRange{
    [self killNotes];
    [self loadLowRange];
}

#pragma mark - Range

-(void)loadLowRange{
    
    _currentScreen = kLowRange;
    
    _lowRangeScreenNode = [SKNode node];
    _lowRangeScreenNode.name = @"LowRangeScreenNode";
    [self addChild:_lowRangeScreenNode];
    
    SKColor *textColor =[UIColor colorWithHue:212.0/360.0 saturation:67.0/100.0 brightness:89.0/100.0 alpha:1.0];
    SKLabelNode *lowRangeLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    lowRangeLabelNode.Name = @"LowRange";
    lowRangeLabelNode.fontSize = 0.07*self.size.height;
    lowRangeLabelNode.fontColor =textColor;
    lowRangeLabelNode.text = @"Play Lowest Note";
    lowRangeLabelNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [_lowRangeScreenNode addChild:lowRangeLabelNode];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeAlphaTo:0.5 duration:1.0],
                                           [SKAction fadeAlphaTo:1.0 duration:0.5]]];
    
                       
    [lowRangeLabelNode runAction:[SKAction repeatActionForever:blink]];
     

}

-(void)killLowRange{
    
    [self enumerateChildNodesWithName:@"LowRangeScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"LowRangeScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
    

}

-(void)transitionLowRangeToHighRange{
    [self killLowRange];
    [self loadHighRange];
}

-(void)loadHighRange{
    
    _currentScreen = kHighRange;
    
    _highRangeScreenNode = [SKNode node];
    _highRangeScreenNode.name = @"HighRangeScreenNode";
    [self addChild:_highRangeScreenNode];
    
    SKLabelNode *highRangeLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    highRangeLabelNode.Name = @"HighRange";
    highRangeLabelNode.fontSize = 0.07*self.size.height;
    highRangeLabelNode.fontColor = [UIColor colorWithHue:212.0/360.0 saturation:67.0/100.0 brightness:89.0/100.0 alpha:1.0];
    highRangeLabelNode.text = @"Play Highest Note";
    highRangeLabelNode.position = CGPointMake(0.5*self.size.width, 0.5*self.size.height);
    [_highRangeScreenNode addChild:highRangeLabelNode];
    
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction fadeAlphaTo:0.5 duration:1.0],
                                           [SKAction fadeAlphaTo:1.0 duration:0.5]]];
    
    
    [highRangeLabelNode runAction:[SKAction repeatActionForever:blink]];
}

-(void)killHighRange{
    [self enumerateChildNodesWithName:@"HighRangeScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"HighRangeScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
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
    
    _currentScreen = kGame;
    _timeRemaining = 60;
    _score = 0;
    
    [_notePressedFlags removeAllObjects];
    
    self.backgroundColor = [UIColor whiteColor];
    
    _gameScreenNode = [SKNode node];
    _gameScreenNode.name = @"GameScreenNode";
    [self addChild:_gameScreenNode];
    
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
    [_gameScreenNode addChild:bassClef];
    
    SKSpriteNode *trebleClef = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"TrebleClef" stringByAppendingString:_deviceSuffix]]];
    trebleClef.name = @"TrebleClef";
    trebleClef.xScale = 0.5;
    trebleClef.yScale = 0.5;
    trebleClef.position = CGPointMake(0.1*self.size.width, 23*self.size.height/(NUMBER_OF_STAFF_LINES + 1));
    [_gameScreenNode addChild:trebleClef];
    
    _currentNameNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _currentNameNode.name = @"NoteName";
    _currentNameNode.fontSize = 0.08*self.size.height;
    _currentNameNode.fontColor = [UIColor blackColor];
    _currentNameNode.position = CGPointMake(0.95*self.size.width, 0.05*self.size.height);
    _currentNameNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    [_gameScreenNode addChild:_currentNameNode];
   
    _timeRemainingNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _timeRemainingNode.name = @"TimeRemaining";
    _timeRemainingNode.fontSize = 0.08*self.size.height;
    _timeRemainingNode.fontColor = [UIColor blackColor];
    _timeRemainingNode.position = CGPointMake(0.95*self.size.width, 0.9*self.size.height);
    _timeRemainingNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _timeRemainingNode.text = [NSString stringWithFormat:@":%i",_timeRemaining];
    [_gameScreenNode addChild:_timeRemainingNode];
    
    _scoreNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    _scoreNode.name = @"Score";
    _scoreNode.fontSize = 0.08*self.size.height;
    _scoreNode.fontColor = [UIColor blackColor];
    _scoreNode.position = CGPointMake(0.05*self.size.width, 0.9*self.size.height);
    _scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreNode.text = [NSString stringWithFormat:@"%i",_score];
    [_gameScreenNode addChild:_scoreNode];
    
    id wait = [SKAction waitForDuration:1];
    id run = [SKAction runBlock:^{
        [self decrementTimeRemaining];
    }];
    [self runAction:[SKAction repeatAction:[SKAction sequence:@[wait, run]] count:_timeRemaining]];
    
    
    //Generate random chord
    [self loadNotesFromChord:_chordCatalog[arc4random_uniform((int)_chordCatalog.count - 1)]];
}

-(void)killGame{
  
    [self enumerateChildNodesWithName:@"GameScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    [self enumerateChildNodesWithName:@"GameScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];

}
-(void)transitionGameToScore{
    [self killGame];
    [self loadScore];
}

-(void)decrementTimeRemaining{
    _timeRemaining--;
    _timeRemainingNode.text = [NSString stringWithFormat:@":%i",_timeRemaining];
}

-(void)removeGameNotes{
    [self enumerateChildNodesWithName:@"Note" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
}



#pragma mark - Score

-(void)loadScore{
    
    _currentScreen = kScore;
    self.backgroundColor = [UIColor darkGrayColor];
    
    _scoreScreenNode = [SKNode node];
    _scoreScreenNode.name = @"ScoreScreenNode";
    [self addChild:_scoreScreenNode];
    
    SKLabelNode *gameOverLabelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-UltraLight"];
    gameOverLabelNode.Name = @"GameOver";
    gameOverLabelNode.fontSize = 0.1*self.size.height;
    gameOverLabelNode.fontColor = [UIColor colorWithHue:212.0/360.0 saturation:67.0/100.0 brightness:89.0/100.0 alpha:1.0];
    gameOverLabelNode.text = @"Game Over";
    gameOverLabelNode.position = CGPointMake(0.5*self.size.width, 0.85*self.size.height);
    [_menuScreenNode addChild:gameOverLabelNode];
    
    SKSpriteNode *scoreBannerNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"ScoreBanner" stringByAppendingString:_deviceSuffix]]];
    scoreBannerNode.name = @"ScoreBanner";
    scoreBannerNode.xScale = 0.5;
    scoreBannerNode.yScale = 0.5;
    scoreBannerNode.position = CGPointMake(0.5*self.size.width, 0.7*self.size.height);
    [_scoreScreenNode addChild:scoreBannerNode];
    
    SKSpriteNode *bestBannerNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"BestBanner" stringByAppendingString:_deviceSuffix]]];
    bestBannerNode.name = @"BestBanner";
    bestBannerNode.xScale = 0.5;
    bestBannerNode.yScale = 0.5;
    bestBannerNode.position = CGPointMake(0.5*self.size.width, scoreBannerNode.position.y - 0.5*scoreBannerNode.size.height - 0.5*bestBannerNode.size.height);
    [_scoreScreenNode addChild:bestBannerNode];
    
    
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
    
    [self enumerateChildNodesWithName:@"ScoreScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllChildren];
    }];
    
    [self enumerateChildNodesWithName:@"ScoreScreenNode" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeFromParent];
    }];
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

-(void)loadStaffLineWithPosition:(CGPoint)position{
    SKSpriteNode *staffLine = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[@"StaffLine" stringByAppendingString:_deviceSuffix]]];
    staffLine.name = @"StaffLine";
    staffLine.xScale = 0.5;
    staffLine.yScale = 0.5;
    staffLine.position = position;
    [_gameScreenNode addChild:staffLine];
    
}

-(void)loadNotesFromChord:(Chord*)chord{
    
    NSArray *notes = chord.notes;
    _currentNotes = notes;
    _currentName = chord.name;
    _currentNameNode.text = _currentName;
    
    
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
        [_gameScreenNode addChild:noteNode];
        
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
        _score = _score + 100;
        _scoreNode.text = [NSString stringWithFormat:@"%i",_score];
    }
    
    
    
}

-(void)checkNoteReleaseWithNumber:(int)userKeyNumber
{
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
        if ([name isEqualToString:@"CMajor"]) {
            _gameData.key = 0;
            [self transitionKeyToStaff];
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
