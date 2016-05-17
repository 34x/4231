//
//  Game.m
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCGame.h"
#import "NCCell.h"
#import "Utils.h"
#import "NCSettings.h"

@interface NCGame()
@property (readwrite, nonatomic) NSUInteger total;
@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic, readwrite) NSUInteger currentNumber;
@property (nonatomic, readwrite) NSUInteger currentIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, readwrite) NSNumber *duration;
@property (nonatomic, readwrite) NSUInteger colorsCount;
@property (nonatomic, readwrite) NSUInteger fontsCount;
@property (nonatomic, readwrite) BOOL isDone;
@property (nonatomic, readwrite) BOOL isComplete;
@property (nonatomic, readwrite) BOOL isStarted;
@property (nonatomic, readwrite) NSUInteger clicked;
@property (nonatomic, readwrite) NSUInteger clickedWrong;
@property (nonatomic, readwrite) NSMutableArray *randomizedSequence;
@property (nonatomic, readwrite) NSDate *startTime;
@property (nonatomic, readwrite) NSDictionary *result;

@property (nonatomic, readwrite) NSUInteger cols;
@property (nonatomic, readwrite) NSUInteger rows;
@end

@implementation NCGame

static NCGame *sharedInstance;

+ (NCGame*) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NCGame alloc] init];
    });
    return sharedInstance;

}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.total = 2;
        self.sequenceLength = 2;
        self.timeLimit = 30;
        self.difficultyLevel = 0;
        self.sequenceLevel = 0;
        self.clicked = 0;
        self.clickedWrong = 0;
        self.currentIndex = 0;
        
        self.isStarted = NO;
        self.isDone = NO;
        self.isComplete = NO;
        self.duration = [NSNumber numberWithFloat:.0];
    }
    
    return self;
}


- (instancetype) initWithTotal:(NSUInteger)total
{
    self = [self init];
    
    if (self) {
        self.total = total;
        self.sequenceLength = total;
    }

    return self;
}

- (void) preparForNewRound {
    NCSettings *settings = [[NCSettings alloc] init];
    NSInteger sequenceLevel = settings.sequence;
    
    sequenceLevel = [NCGame checkSequenceLevel:sequenceLevel];
    self.sequenceLevel = sequenceLevel;
    
    NSDictionary *sequenceParams = [NCGame getSequenceParams:self.sequenceLevel];
    NCSequenceSettings *ssettings = [settings getSequenceSettings:[sequenceParams objectForKey:@"id"]];
    
    NSUInteger sequenceLength = ssettings.sequenceLength;

    NSInteger boardIndex = [NCSettings getCloserBoardIndex:sequenceLength];
    NSInteger currentBoardIndex = ssettings.boardIndex;
    
    self.difficultyLevel = ssettings.difficultyLevel;
    
    // if in some cases we have wrong board size, fix it here
    if (currentBoardIndex < boardIndex) {
        ssettings.boardIndex = boardIndex;
    }
    
    
    [settings save];
    
    
    NSArray *boards = [NCSettings getBoardSizes];
    NSArray *cBoard = [boards objectAtIndex:ssettings.boardIndex];
    
    self.cols = [cBoard[0] intValue];
    self.rows = [cBoard[1] intValue];
    self.sequenceLength = sequenceLength;
    
#if DEBUG
    self.cols = 4;
    self.rows = 6;
    self.difficultyLevel = 2;
//    self.sequenceLength = 4;
#endif


    self.sequenceId = [sequenceParams objectForKey:@"symbols"];
    
    if (0 == self.difficultyLevel) {
        ssettings.lastResult = 0.0;
        [settings save];
    }
    
    self.currentIndex = 0;
    self.clicked = 0;
    self.clickedWrong = 0;
    self.isStarted = NO;
    self.isDone = NO;
    self.isComplete = NO;
    self.total = self.cols * self.rows;
    
    
#warning need to eliminate this inconvinient call
    [self getItems];
}


- (NSMutableArray*)items
{
    if (!_items) _items = [[NSMutableArray alloc] init];
    return _items;
}

- (BOOL)select:(NSString*)value
{
    NSString *current = self.sequence[self.currentIndex];
    
    if ([current isEqualToString:value]) {
        self.currentIndex++;
        self.clicked++;
        
        if (self.currentIndex >= [self.sequence count]) {
            self.isComplete = YES;
            [self finish];
        }

        return YES;
    } else {
        self.clickedWrong++;
        
        if (self.clickedWrong >= self.sequenceLength) {
            [self finish];
        }
        
        return NO;
    }
}

- (NSNumber*) getDuration {

    if (self.isStarted && !self.isDone) {
        NSDate *currentTime = [NSDate date];
        NSTimeInterval timeDifference =  [currentTime timeIntervalSinceDate:self.startTime];
        self.duration = [NSNumber numberWithDouble:timeDifference];
    }
    
    return self.duration;
}

- (BOOL)getIsDone {
    if ([[self getDuration] floatValue] >= [[NSNumber numberWithInteger:self.timeLimit] floatValue]) {
        self.isDone = YES;
    }
    
    return self.isDone;
}

+ (NSArray*)getSymbols:(NSString*)key {
    //    @[@"А", @"Б", @"В", @"Г", @"Д", @"Е", @"Ж", @"З", @"И", @"К", @"Л", @"М", @"Н", @"О", @"П", @"Р", @"С", @"Т", @"У", @"Ф", @"Х", @"Ц", @"Ч", @"Ш", @"Щ", @"Ъ", @"Ы", @"Ь", @"Э", @"Ю", @"Я"];
    
    NSMutableArray *numbersFrom1 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < 100; i++) {
        [numbersFrom1 addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    NSMutableArray *numbersFrom0 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 100; i++) {
        [numbersFrom0 addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    NSDictionary *symbols = @{
                              @"numbersFrom1" : numbersFrom1,
                              @"numbers" : numbersFrom0,
                              @"numbers09": @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"-"],
                              @"numbersLetters" : @[
                                                    @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                                                    @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    @"%", @"&", @"-", @"@", @"#"
                                                    ],
                              
                              @"letters" : @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                                             @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
                                             @"X", @"Y", @"Z"],
                              @"emoji" : @[@"👻", @"👽", @"👾", @"🌲", @"🌳", @"🌴", @"🌷", @"🌸", @"🌻", @"💐", @"🌿", @"🍀", @"🍁", @"🍂", @"🍃", @"🍄", @"🌰", @"🐾", @"🔥", @"☀️", @"⛅", @"️☁️", @"💧", @"💦", @"☔️", @"❄️", @"🌐", @"🌍", @"🌚", @"🌝", @"🍅", @"🍇", @"🍉", @"🍍", @"🍏", @"🍐", @"🍒", @"🍕", @"🍭", @"🍰", @"🍳", @"🍴", @"🎀", @"🎁", @"🎃", @"🎄", @"🎉", @"🎈", @"💥", @"🎓", @"⛄", @"🎣", @"⚽", @"🏀", @"🏈", @"️⚾️", @"🏁", @"🎹", @"🎸", @"🎵", @"🎶", @"🎼", @"🎭", @"🎩", @"🎪", @"🎬", @"🎨", @"🎯", @"🎱", @"🚂", @"🚋", @"🚌", @"🚑", @"🚒", @"🚓", @"🚜", @"🚲", @"🚧", @"🚦", @"🚀", @"🚁", @"✈️", @"⚓️", @"⛵", @"🚠", @"🏠", @"🏫", @"🏥", @"⌚", @"📱", @"💻", @"⏰", @"📷", @"🎥", @"📺", @"📻", @"📟", @"☎️", @"💽", @"💾", @"💿", @"💡", @"🔦", @"📡", @"💰", @"💎", @"🌂", @"💼", @"👓", @"🚪", @"💊", @"🔮", @"🔭", @"🔨", @"📰", @"🔑", @"✉️", @"📦", @"📄", @"📆", @"📖", @"📎", @"📌", @"📐", @"🚩", @"🔒", @"📢", @"🔔"],
                              
                              
                              
                              @"katakana" : @[@"ア",@"イ",@"ウ",@"エ",@"オ",@"カ",@"キ",@"ク",@"ケ",@"コ",@"サ",@"シ",@"ス",@"セ",@"ソ"],
                              @"flags" : @[@"🇦🇺", @"🇦🇹", @"🇧🇪", @"🇧🇷", @"🇨🇦", @"🇨🇱", @"🇨🇳", @"🇨🇴", @"🇩🇰", @"🇫🇮", @"🇫🇷", @"🇩🇪", @"🇭🇰", @"🇮🇳", @"🇮🇩", @"🇮🇪", @"🇮🇱", @"🇮🇹", @"🇯🇵", @"🇰🇷", @"🇲🇴", @"🇲🇾", @"🇲🇽", @"🇳🇱", @"🇳🇿", @"🇳🇴", @"🇵🇭", @"🇵🇱", @"🇵🇹", @"🇵🇷", @"🇷🇺", @"🇸🇦", @"🇸🇬", @"🇿🇦", @"🇪🇸", @"🇸🇪", @"🇨🇭", @"🇹🇷", @"🇬🇧", @"🇺🇸", @"🇦🇪", @"🇻🇳"],
                              @"faces" : @[@"👰🏼", @"👱🏾", @"👲🏾", @"👳🏾", @"👴🏻", @"👵🏼", @"👮🏼", @"👷", @"👸🏽", @"💂🏻",@"🎅🏼", @"🙇🏻", @"🙇🏼", @"💁🏻", @"💁🏼", @"🙅🏼", @"🙅🏽",  @"🙆🏻", @"🙆🏼", @"🙋", @"🙋🏻", @"🙎🏼", @"🙎🏿", @"🙍🏼", @"🙍🏾", @"🐼", @"🤖", @"🦁", @"🐸"],
                              };

    return symbols[key];
}

+ (NSArray*)getSequencesParams {

    NSArray *sequencesSettings = @[
                   @{
                       @"id" : @"randomNumbers",
                       @"symbols" : @"numbers09",
                       @"label"   : @"Random numbers",
                       @"generator" : @"getRandomizedSequence:"
                       },
//                     @{
//                         @"id" : @"numbers",
//                         @"symbols" : @"numbersFrom1",
//                         @"label" : @"Numbers",
//                         @"generator" : @"getSlicedSequence:"
//                         },
//                     @{
//                         @"id" : @"letters",
//                         @"symbols" : @"letters",
//                         @"label" : @"Letters",
//                         @"generator" : @"getSlicedSequence:"
//                         },
                     @{
                         @"id" : @"randomNumbersLetters",
                         @"symbols" : @"numbersLetters",
                         @"label"   : @"Random numbers & letters",
                         @"generator" : @"getRandomizedSequence:",
                         },
                     @{
                         @"id" : @"emoji",
                         @"symbols" : @"emoji",
                         @"label" : @"Random emoji",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"id" : @"randomFlags",
                         @"symbols" : @"flags",
                         @"label"   : @"Random flags",
                         @"generator" : @"getRandomizedSequence:"
                         },
//                     @{
//                         @"id" : @"katakana",
//                         @"symbols" : @"katakana",
//                         @"label" : @"Katakana",
//                         @"generator" : @"getSlicedSequence:"
//                         },
                     @{
                         @"id" : @"randomKatakana",
                         @"symbols" : @"katakana",
                         @"label"   : @"Random katakana",
                         @"generator" : @"getRandomizedSequence:"
                         },
                    @{
                       @"id" : @"faces",
                       @"symbols" : @"faces",
                       @"label"   : @"Random faces",
                       @"generator" : @"getRandomizedSequence:"
                       },
                     ];
    
    return sequencesSettings;
}

+ (NSUInteger)checkSequenceLevel:(NSUInteger)level {
    NSArray *sequencesSettings = [NCGame getSequencesParams];
    if (level > [sequencesSettings count] - 1) {
        level = 0;
    }
    
    return level;
}

+ (NSDictionary*)getSequenceParams:(NSUInteger)level {
    NSArray *sequencesSettings = [NCGame getSequencesParams];
    
    if (level > [sequencesSettings count] - 1) {
        level = 0;
    }
    
    NSDictionary *settings = [sequencesSettings objectAtIndex:level];
    
    return settings;
}

+ (NSString*)getSequenceId:(NSUInteger)level {
    NSDictionary *settings = [NCGame getSequenceParams:level];
    
    return [settings objectForKey:@"id"];
}

- (NSMutableArray*)getSequence:(NSUInteger)sequenceLevel difficultyLevel:(NSUInteger)difficultyLevel {
    NSMutableArray *sequence;

    NSDictionary *params = [NCGame getSequenceParams:sequenceLevel];
    
    NSMutableArray *symbols = [[NCGame getSymbols:[params objectForKey:@"symbols"]] mutableCopy];
    
    if (nil == [params objectForKey:@"generator"]) {
        sequence = [NCGame createLimitSequence:self.sequenceLength symbols:symbols];
    } else {
        SEL selector = NSSelectorFromString([params objectForKey:@"generator"]);

        sequence = [self performSelector:selector withObject:symbols];

        sequence = [NCGame createLimitSequence:self.sequenceLength symbols:sequence];
    }
    
    return sequence;
}

+ (NSMutableArray*)createLimitSequence:(NSUInteger)total symbols:(NSArray*)symbols {
    NSMutableArray *sequence = [[NSMutableArray alloc] init];
    
    NSString *val;
    
    NSUInteger idx = 0;
    while ([sequence count] < total) {
        val = [NSString stringWithFormat:@"%@", [symbols objectAtIndex:idx]];
    
        [sequence addObject:[NSString stringWithFormat:@"%@", val]];
        if (++idx >= [symbols count]) {
            idx = 0;
        }
    }

    return sequence;
}

- (void)generateItems:(BOOL)reverse {

    self.items = [NSMutableArray new];
    NSDictionary *params = [NCGame getSequenceParams:self.sequenceLevel];
    
    NSMutableArray *symbols = [[NCGame getSymbols:[params objectForKey:@"symbols"]] mutableCopy];
    
    symbols = [[self getRandomizedSequence:symbols] mutableCopy];


    
    for (int i = 0; i < [self.sequence count]; i++) {
        NCCell *cell = [[NCCell alloc] init];
        
        cell.text = self.sequence[i];
        [self.items addObject:cell];
    }

    int idx = 0;
    int iterationCount = 0;

    while ([self.items count] < self.total) {
        if (idx >= [symbols count]) {
            idx = 0;
            iterationCount++;
        }
        
        NSString *symbol = symbols[idx];
        idx++;
        
        if (iterationCount < 4 && NSNotFound != [self.sequence indexOfObject:symbol]) {
            continue;
        }
        
        NCCell *cell = [[NCCell alloc] init];
        
        cell.text = symbol;
        [self.items addObject:cell];
    }
}

+ (NSMutableArray*)randomize:(NSMutableArray*)itemsOriginal {
    NSMutableArray *items = [itemsOriginal mutableCopy];
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal {    
    return [Utils getRandomizedSequence:sequenceOriginal];
}

- (NSArray*)getSlicedSequence:(NSArray*)sequenceOriginal {
    NSMutableArray *items = sequenceOriginal.mutableCopy;
    if (self.total > [items count]) {
        return items;
    }
    
    int offset = arc4random() % ([items count] - self.total);
    
    for (int i = 0; i < offset; i++) {
        [items removeObjectAtIndex:0];
    }
    
    return items;
}

- (NSArray*) getItems {

    // filling up
    self.sequence = [self getSequence:self.sequenceLevel difficultyLevel:self.difficultyLevel];
    [self generateItems:NO];
    
    //randomizing few times
    for (int i = 0; i < 5; i++) {
        self.items = [NCGame randomize:self.items];
    }
    
    return self.items;
}

- (void) start
{
    self.startTime = [NSDate date];
    self.isStarted = YES;
}
- (NSDictionary*) finish
{
    [self getDuration];
    
    if (self.isDone) {
        return self.result;
    }
    
    self.isDone = YES;
    
    if (self.isComplete) {
        NSLog(@"GAME IS DONE!");

        NSDate *date = [NSDate date];
        
        NSUserDefaults *def = [[NSUserDefaults alloc] init];
        // seems like a hack
        id obj = [def objectForKey:@"log"];
        NSMutableArray *log;
        if (nil == obj) {
            log = [[NSMutableArray alloc] init];
        } else {
            log = [obj mutableCopy];
            for (NSUInteger i = 0; i < [log count]; i++) {
                id obj = [log objectAtIndex:i];
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    [log removeObjectAtIndex:i];
                }
            }
        }
        
        NSDictionary *settings = [NCGame getSequenceParams:self.sequenceLevel];

        self.result = @{
                                @"date" : date,
                                @"sequenceCount" : [NSNumber numberWithInteger:self.sequenceLength],
                                @"total" : [NSNumber numberWithInteger:self.total],
                                @"id" : [settings objectForKey:@"id"],
                                @"difficulty" : [NSNumber numberWithInteger:self.difficultyLevel],
                                @"duration" : self.duration,
                                @"clicked" : [NSNumber numberWithInteger:self.clicked],
                                @"clickedWrong" : [NSNumber numberWithInteger:self.clickedWrong],
                             };

        [log addObject:self.result];
        
        [def setObject:log forKey:@"log"];
        [def synchronize];

    } else {
        NSLog(@"game not done :(");
    }

    return self.result;
}

- (float)getSpeed {
    return (float)self.clicked / ([[self getDuration] floatValue]);
}

+ (NSMutableArray*)log {
    NSUserDefaults *def = [[NSUserDefaults alloc] init];
    NSMutableArray *log = [def objectForKey:@"log"];

    if (!log) {
        log = [[NSMutableArray alloc] init];
    }
    return log;
}

+ (NSNumber*)getScore:(NSDictionary*)data {
    NSNumber *score = [NSNumber numberWithFloat:0.0];
    
    NSArray *sparams = [NCGame getSequencesParams];
    NSString *skey = [data objectForKey:@"id"];
    
    NSNumber *sequenceIndex = [NSNumber numberWithInt:0];
    for (int i = 0; i < [sparams count]; i++) {
        NSDictionary *param = [sparams objectAtIndex:i];
        if ([skey isEqualToString:[param objectForKey:@"id"]]) {
            sequenceIndex = [NSNumber numberWithInt:i];
            break;
        }
    }
    
    float total = [[data objectForKey:@"total"] floatValue];
    float sequenceCount = [[data objectForKey:@"sequenceCount"] floatValue];
    if (sequenceCount < 2.) {
        sequenceCount = 2.;
    }

    float duration = [[data objectForKey:@"duration"] floatValue];
    float speed = 1.0;
    if (duration > 0.0) {
        speed = sequenceCount / duration;
    }

    float speedBonus = speed + sequenceCount + total;
    float sizeBonus = (sequenceCount * sequenceCount * sequenceCount) + (total * total);
    

    score = [NSNumber numberWithFloat:speedBonus + sizeBonus];
    

    float percent = [score floatValue] / 100.;
    float difficulty = [[data objectForKey:@"difficulty"] floatValue];
    
    float difficultyBonus = (percent*difficulty*10.) * difficulty;
    
    
//    NSLog(@"SCORE base (speed, total) %@, difbonus %.2f", score, difficultyBonus);
    
    score = [NSNumber numberWithFloat:[score floatValue] + difficultyBonus ];
//    NSLog(@"SCORE difficult %@", score);
    
    percent = [score floatValue] / 100.;
    
    float sequenceBonus = (percent*20.) * [sequenceIndex floatValue];
    
    score = [NSNumber numberWithFloat:[score floatValue] + sequenceBonus ];
//    NSLog(@"SCORE sequence %@, sbonus %.2f", score, sequenceBonus);

    percent = [score floatValue] / 100.;
    
    score = [NSNumber numberWithFloat:[score floatValue] - (percent*10) * [[data objectForKey:@"clickedWrong"] floatValue] ];
//    NSLog(@"SCORE wrong %@", score);
    
    
    if (nil == score || isnan([score floatValue])) {
        score = [NSNumber numberWithFloat:0.0];
    } else {
        score = [NSNumber numberWithFloat:[score floatValue] / 4.0 / 10.0];
    }
    
    return score;
}

+ (NSMutableDictionary*)stats:(NSString*)keyFormat fromDate:(NSDate*)fromDate {

    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *days = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];

    if (0 == [log count]) {
        return stats;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:keyFormat];
    
    NSNumber *totalMax = @0;
    NSNumber *totalAvg = @0;
    NSNumber *totalMin = @0;

    for (id obj in log) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSDictionary *item = obj;
        float gameScore = [[NCGame getScore:item] floatValue];
        
        NSDate *date = [item objectForKey:@"date"];
//        NSLog(@"%@ ? %@", [formatter stringFromDate:date], [formatter stringFromDate:fromDate]);
        if (nil != fromDate && [date compare:fromDate] == NSOrderedAscending) {
            continue;
        }
        
        // calculate item value
        float time  = [[item objectForKey:@"duration"] floatValue];
        
        if (!time || time > 1000000) {
            continue;
        }
        
        NSString *dayKey = [formatter stringFromDate:date];
        
        /*
         
         dayLog [
            date = [
                avg   = ...
                max   = ...
                min   = ...
            ],
            avg = ...
            max = ...
            min = ...
         ]
         
         */
        
        NSMutableDictionary *dayLog = [days objectForKey:dayKey];
        if (nil == dayLog) {
            dayLog = [[NSMutableDictionary alloc] init];
            days[dayKey] = dayLog;
        }

        
        NSNumber *dayAvg = [dayLog objectForKey:@"avg"];
        NSNumber *dayMax = [dayLog objectForKey:@"max"];
        NSNumber *dayMin = [dayLog objectForKey:@"min"];
        NSNumber *daySum = [dayLog objectForKey:@"sum"];
        
        if (nil == dayAvg) {
            dayAvg = [NSNumber numberWithFloat:gameScore];
        } else {
            dayAvg = [NSNumber numberWithFloat:([dayAvg floatValue] + gameScore) / 2.];
        }
        
        if (nil == dayMax || [dayMax floatValue] < gameScore) {
            dayMax = [NSNumber numberWithFloat:gameScore];
        }

        if (nil == dayMin || [dayMin floatValue] > gameScore) {
            dayMin = [NSNumber numberWithFloat:gameScore];
        }
        
        if (nil == daySum) {
            daySum = [NSNumber numberWithFloat:gameScore];
        } else {
            daySum = [NSNumber numberWithFloat:([daySum floatValue] + gameScore)];
        }
        
        [dayLog setObject:dayAvg forKey:@"avg"];
        [dayLog setObject:dayMax forKey:@"max"];
        [dayLog setObject:dayMin forKey:@"min"];
        [dayLog setObject:daySum forKey:@"sum"];

        if (nil == totalAvg) {
            totalAvg = [NSNumber numberWithFloat:gameScore];
        } else {
            totalAvg = [NSNumber numberWithFloat:([totalAvg floatValue] + gameScore) / 2.];
        }
        
        if (nil == totalMax || [totalMax floatValue] < gameScore) {
            totalMax = [NSNumber numberWithFloat:gameScore];
        }
        
        if (nil == totalMin || [totalMin floatValue] > gameScore) {
            totalMin = [NSNumber numberWithFloat:gameScore];
        }
    }
    
    [stats setObject:totalMax forKey:@"max"];
    [stats setObject:totalAvg forKey:@"avg"];
    [stats setObject:totalMin forKey:@"min"];
    [stats setObject:days forKey:@"days"];
    
    return stats;
}


-(NSArray<UIView*>*) getCrazyCellsForSize:(CGSize)boardSize andCount:(NSInteger)targetCount {
    
    NSMutableArray<UIView*> *cells = [NSMutableArray new];
    
    NSInteger iteration = 0;
    
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boardSize.width, boardSize.height)];
    [cells addObject:cell];
    CGFloat minWidth  = boardSize.width / (targetCount / 2.0);
    CGFloat minHeight = boardSize.height / (targetCount / 2.0);
    
    minWidth = MAX(112, minWidth);
    minHeight = MAX(112, minHeight);
    
    UIView *cell1;
    UIView *cell2;
    UIView *divideCell;
    
    while (cells.count < targetCount) {
        if (iteration++ > 5000) {
            break;
        }
        cell1 = nil;
        cell2 = nil;
        divideCell = nil;
        
        for(UIView *cell in cells) {
            
            divideCell = cell;
            
            CGFloat width = cell.frame.size.width;
            CGFloat height = cell.frame.size.height;
            
            CGFloat randomWidth = width * 0.1;
            CGFloat randomHeight = height * 0.1;
            
            NSInteger divideChance = 10;
            NSInteger divideChance2 = 4;
            BOOL divideHorisontal = NO;
            BOOL divideVertical = NO;
            
            if (MIN(width, height) / MAX(width, height) < 0.5) {
                divideChance = 4;
                divideChance2 = divideChance - 2;
            }
            
            if (width > height) {
                divideHorisontal = YES;
            } else {
                divideVertical = YES;
            }
            
            if (divideHorisontal && width >= minWidth && 0 == arc4random() % divideChance) {
                randomWidth = randomWidth * -1;
                width = width / 2.0 + randomWidth;
                cell1 = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, width, height)];
                cell2 = [[UIView alloc] initWithFrame:CGRectMake(cell1.frame.origin.x + width, cell1.frame.origin.y, cell.frame.size.width - width, height)];
                break;
            } else if (divideVertical && height >= minHeight && 0 == arc4random() % divideChance) {
                height = height / 2.0 + randomHeight;
                cell1 = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, width, height)];
                cell2 = [[UIView alloc] initWithFrame:CGRectMake(cell1.frame.origin.x, cell1.frame.origin.y + height, width, cell.frame.size.height - height)];
                break;
            }
            
        }
        
        if (cell1 && cell2) {
            NSUInteger idx = [cells indexOfObject:divideCell];
            
            [cells replaceObjectAtIndex:idx withObject:cell1];
            [cells addObject:cell2];
        }
        
        [cells sortUsingComparator:^NSComparisonResult(UIView *obj1, UIView  *obj2) {
            CGFloat size1 = obj1.frame.size.width * obj1.frame.size.height;
            CGFloat size2 = obj2.frame.size.width * obj2.frame.size.height;
            
            if (size1 > size2) {
                return NSOrderedAscending;
            } else if (size1 < size2) {
                return NSOrderedDescending;
            }
            
            return NSOrderedSame;
            
        }];
    }
    
    if (targetCount != cells.count) {
        NSLog(@"Total cells: %li / %li", cells.count, targetCount);
    }
    
    return cells;
}


@end
