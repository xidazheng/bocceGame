//
//  ViewController.m
//  BocceGame
//
//  Created by Xida Zheng on 11/4/14.
//  Copyright (c) 2014 xidazheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic) CGPoint startingLocation;
@property (strong, nonatomic) UIDynamicItemBehavior *linearVelocity;
@property (strong, nonatomic) UICollisionBehavior *collision;
@property (strong, nonatomic) UIView *currentBlock;
@property (strong, nonatomic) UIView *targetBlock;
@property (nonatomic) NSInteger blocksMade;
@property (nonatomic) NSInteger redBlocks;
@property (nonatomic) NSInteger blueBlocks;
@property (nonatomic) BOOL justMadeBlock;
@property (nonatomic) BOOL notSuccessfullyThrown;
@property (strong, nonatomic) UILabel *turnIndicator;

@property (nonatomic, strong) CAShapeLayer *redBall1;
@property (nonatomic, strong) CAShapeLayer *redBall2;
@property (nonatomic, strong) CAShapeLayer *redBall3;
@property (nonatomic, strong) CAShapeLayer *redBall4;
@property (nonatomic, strong) CAShapeLayer *blueBall1;
@property (nonatomic, strong) CAShapeLayer *blueBall2;
@property (nonatomic, strong) CAShapeLayer *blueBall3;
@property (nonatomic, strong) CAShapeLayer *blueBall4;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;
    self.blocksMade = 0;
    self.redBlocks = 0;
    self.blueBlocks = 0;
    self.justMadeBlock = NO;
    self.notSuccessfullyThrown = NO;
    
    //make a green start pad to show where you have to release the box
    CALayer *green = [[CALayer alloc] init];
    green.frame = CGRectMake(0, self.view.frame.size.height - 175, self.view.frame.size.width, 175);
    green.backgroundColor = [[UIColor greenColor] CGColor];
    green.zPosition = -1;
    [self.view.layer addSublayer:green];
    
    //initialize turn indicator
    self.turnIndicator = [[UILabel alloc] init];
    self.turnIndicator.frame = CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height/2 - 25, 300, 50);
    self.turnIndicator.textAlignment = NSTextAlignmentCenter;
    [self.turnIndicator setAlpha:0.0];
    [self.view addSubview:self.turnIndicator];
    
    [self initializeTheBlockCounters];
    
    
    //initialize collision behavior
    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.collisionDelegate = self;
    [self.collision setTranslatesReferenceBoundsIntoBoundary:YES];
    [self.collision setCollisionMode:UICollisionBehaviorModeEverything];
    
    //add initial boundary for jack (the target ball)
    [self.collision addBoundaryWithIdentifier:@"end" fromPoint:CGPointMake(0, self.view.frame.size.height*0.1) toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height*0.1)];
    
    [self.animator addBehavior:self.collision];
    
    //initialize linearVelocity
    self.linearVelocity = [[UIDynamicItemBehavior alloc] init];
    self.linearVelocity.elasticity = 0.05;
    self.linearVelocity.resistance = 4;
    self.linearVelocity.angularResistance = 4;
    
    //make block
    [self makeBlockWithColor:[UIColor blackColor]];
}

- (void) initializeTheBlockCounters
{
    CGFloat windowWidth = self.view.frame.size.width;
    CGFloat windowHeight = self.view.frame.size.height;
    
    //initialize the 4 balls on each side
    self.redBall1 = [[CAShapeLayer alloc] init];
    self.redBall1.frame = CGRectMake(windowWidth * 0.1, windowHeight * 0.8, windowWidth * 0.025, windowWidth * 0.025);
    self.redBall1.path = CGPathCreateWithEllipseInRect(self.redBall1.bounds, NULL);
    self.redBall1.fillColor =[UIColor redColor].CGColor;
    self.redBall1.lineWidth = 1;
    
    //initialize the 4 balls on each side
    self.redBall2 = [[CAShapeLayer alloc] init];
    self.redBall2.frame = CGRectMake(windowWidth * 0.1, windowHeight * 0.825, windowWidth * 0.025, windowWidth * 0.025);
    self.redBall2.path = CGPathCreateWithEllipseInRect(self.redBall2.bounds, NULL);
    self.redBall2.fillColor =[UIColor redColor].CGColor;
    self.redBall2.lineWidth = 1;
    
    //initialize the 4 balls on each side
    self.redBall3 = [[CAShapeLayer alloc] init];
    self.redBall3.frame = CGRectMake(windowWidth * 0.1, windowHeight * 0.85, windowWidth * 0.025, windowWidth * 0.025);
    self.redBall3.path = CGPathCreateWithEllipseInRect(self.redBall3.bounds, NULL);
    self.redBall3.fillColor =[UIColor redColor].CGColor;
    self.redBall3.lineWidth = 1;
    
    //initialize the 4 balls on each side
    self.redBall4 = [[CAShapeLayer alloc] init];
    self.redBall4.frame = CGRectMake(windowWidth * 0.1, windowHeight * 0.875, windowWidth * 0.025, windowWidth * 0.025);
    self.redBall4.path = CGPathCreateWithEllipseInRect(self.redBall4.bounds, NULL);
    self.redBall4.fillColor =[UIColor redColor].CGColor;
    self.redBall4.lineWidth = 1;
    
    [self.view.layer addSublayer:self.redBall1];
    [self.view.layer addSublayer:self.redBall2];
    [self.view.layer addSublayer:self.redBall3];
    [self.view.layer addSublayer:self.redBall4];
    
    //initialize the 4 balls on each side
    self.blueBall1 = [[CAShapeLayer alloc] init];
    self.blueBall1.frame = CGRectMake(windowWidth * 0.875, windowHeight * 0.8, windowWidth * 0.025, windowWidth * 0.025);
    self.blueBall1.path = CGPathCreateWithEllipseInRect(self.blueBall1.bounds, NULL);
    self.blueBall1.fillColor =[UIColor blueColor].CGColor;
    self.blueBall1.lineWidth = 1;
    
    //initialize the 4 balls on each side
    self.blueBall2 = [[CAShapeLayer alloc] init];
    self.blueBall2.frame = CGRectMake(windowWidth * 0.875, windowHeight * 0.825, windowWidth * 0.025, windowWidth * 0.025);
    self.blueBall2.path = CGPathCreateWithEllipseInRect(self.blueBall2.bounds, NULL);
    self.blueBall2.fillColor =[UIColor blueColor].CGColor;
    self.blueBall2.lineWidth = 1;
    
    //initialize the 4 balls on each side
    self.blueBall3 = [[CAShapeLayer alloc] init];
    self.blueBall3.frame = CGRectMake(windowWidth * 0.875, windowHeight * 0.85, windowWidth * 0.025, windowWidth * 0.025);
    self.blueBall3.path = CGPathCreateWithEllipseInRect(self.blueBall3.bounds, NULL);
    self.blueBall3.fillColor =[UIColor blueColor].CGColor;
    self.blueBall3.lineWidth = 1;
    
    //initialize the 4 balls on each side
    self.blueBall4 = [[CAShapeLayer alloc] init];
    self.blueBall4.frame = CGRectMake(windowWidth * 0.875, windowHeight * 0.875, windowWidth * 0.025, windowWidth * 0.025);
    self.blueBall4.path = CGPathCreateWithEllipseInRect(self.blueBall4.bounds, NULL);
    self.blueBall4.fillColor =[UIColor blueColor].CGColor;
    self.blueBall4.lineWidth = 1;
    
    [self.view.layer addSublayer:self.blueBall1];
    [self.view.layer addSublayer:self.blueBall2];
    [self.view.layer addSublayer:self.blueBall3];
    [self.view.layer addSublayer:self.blueBall4];

}


- (void)viewDidLayoutSubviews
{
    NSLog(@"%@", self.redBall1);
}

- (void) makeBlockWithColor:(UIColor *)color
{
    //init block
    self.currentBlock = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- 22.5, self.view.frame.size.height - 85, 45, 45)];
    self.currentBlock.backgroundColor = color;
    [self.view addSubview:self.currentBlock];
    
    //add draggable behavior, only one object should have draggable behavior and it should be reassigned when a new block is created
    UIPanGestureRecognizer *draggable = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    
    [self.currentBlock addGestureRecognizer:draggable];
    [self.collision addItem:self.currentBlock];
    [self.linearVelocity addItem:self.currentBlock];
    
    
    if (color == [UIColor redColor]) {
        self.redBlocks++;
    }else if (color == [UIColor blueColor]) {
        self.blueBlocks++;
    }
    
    //hide block indictors
    [self updateBlockIndicators];
    
    self.blocksMade++;
    self.justMadeBlock = YES;
}
//get the delegate for the animation and when the animation is done make the next block

- (void) updateBlockIndicators
{
    switch (self.redBlocks) {
        case 1:
            [self.redBall1 setHidden:YES];
            break;
            
        case 2:
            [self.redBall2 setHidden:YES];
            break;
            
        case 3:
            [self.redBall3 setHidden:YES];
            break;
            
        case 4:
            [self.redBall4 setHidden:YES];
            break;
            
        default:
            break;
    }
    
    switch (self.blueBlocks) {
        case 1:
            [self.blueBall1 setHidden:YES];
            break;
            
        case 2:
            [self.blueBall2 setHidden:YES];
            break;
            
        case 3:
            [self.blueBall3 setHidden:YES];
            break;
            
        case 4:
            [self.blueBall4 setHidden:YES];
            break;
            
        default:
            break;
    }
    
}


- (void) dragged:(UIPanGestureRecognizer *)gesture
{
    if (![self.animator isRunning]) {
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
                
                self.startingLocation = gesture.view.center;
                NSLog(@"Began %f %f", self.startingLocation.x, self.startingLocation.y);
                
                

                break;
                
            case UIGestureRecognizerStateChanged:
            {
                CGPoint translation = [gesture translationInView:self.view];
                
                CGFloat newX = translation.x + self.startingLocation.x;
                CGFloat newY = translation.y + self.startingLocation.y;
                NSLog(@"Changed %f %f", newX, newY);
                
                gesture.view.center = CGPointMake(newX, newY);
                
                if (newY < self.view.frame.size.height - 175) {
                    NSLog(@"should reset");
                }
                
                break;
            }
                
            case UIGestureRecognizerStateEnded:
                //figure out the velocity and add it to the item
            {
                [self.animator removeBehavior:self.linearVelocity];
                
                CGPoint translation = [gesture translationInView:self.view];
                CGFloat endX = translation.x + self.startingLocation.x;
                CGFloat endY = translation.y + self.startingLocation.y;
                NSLog(@"Ended %f %f", endX, endY);
                
                
                if (endY < self.view.frame.size.height - 175) {
                    NSLog(@"should reset");
                    
                    gesture.view.center = self.startingLocation;
                    self.notSuccessfullyThrown = YES;
                }else if ([gesture velocityInView:self.view].y < 0){
                    
                    CGPoint velocity = [gesture velocityInView:self.view];
                    NSLog(@"%f %f",[gesture velocityInView:self.view].x, [gesture velocityInView:self.view].y);
                    
                    [self.linearVelocity addLinearVelocity:velocity forItem:gesture.view];
                    [self.animator addBehavior:self.linearVelocity];
                    [self.animator updateItemUsingCurrentState:gesture.view];
                    
                    [gesture.view setUserInteractionEnabled:NO];
                    self.notSuccessfullyThrown = NO;
                    
                }
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    if (self.justMadeBlock || self.notSuccessfullyThrown) {
        self.justMadeBlock = NO;
        self.notSuccessfullyThrown = NO;
    }
    //all blocks have been thrown
    else if (self.blocksMade == 9)
    {
        //end the game
        //check the winner
        UIColor *winningColor = [self updateBlockMarking];
        if (winningColor == [UIColor blueColor]) {
            self.turnIndicator.text = @"Winner: Team Blue";
        }else {
            self.turnIndicator.text = @"Winner: Team Red";
        }
    }
    //middle of gameplay
    else
    {
        if (self.currentBlock.backgroundColor == [UIColor blackColor]) {
            //check that the ball is within the target range and reset if not
            self.targetBlock = self.currentBlock;
            [self.collision removeItem:self.currentBlock];
            [self.collision removeBoundaryWithIdentifier:@"end"];
            [self.collision setTranslatesReferenceBoundsIntoBoundary:NO];
            [self.collision addBoundaryWithIdentifier:@"outOfBounds" forPath:[UIBezierPath bezierPathWithRect:CGRectMake(-90, -90, self.view.frame.size.width+180, self.view.frame.size.height+180)]];
        }
        
        [self makeNextBlock];
    }
}

- (void) makeNextBlock
{
    UIColor *winningColor = [self updateBlockMarking];
    if ((winningColor != [UIColor redColor] && self.redBlocks < 4) || (winningColor == [UIColor redColor] && self.blueBlocks >= 4)) {
        UIColor *nextColor = [UIColor redColor];
        [self makeBlockWithColor:nextColor];
        self.turnIndicator.text = @"Up next: Team Red";
        
    }else {
        UIColor *nextColor = [UIColor blueColor];
        [self makeBlockWithColor:nextColor];
        self.turnIndicator.text = @"Up next: Team Blue";
        [UIView animateKeyframesWithDuration:1.5 delay:0 options:UIViewKeyframeAnimationOptionAutoreverse| UIViewKeyframeAnimationOptionRepeat animations:^{
            [self.turnIndicator setAlpha:1.0];
        } completion:nil];
    }
}

- (UIColor *)updateBlockMarking
{
    [self unmarkAllBlocks];
    NSArray *blocks = [self checkClosestBlocksToTargetBlock];
    [self markWinningBlocksWithBlocks:blocks];
    
    if ([blocks count] > 0) {
        NSDictionary *winningBlock = blocks[0];
        return (UIColor *)winningBlock[@"team"];
    }
    return [UIColor redColor];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if ([((NSString *)identifier) isEqualToString:@"outOfBounds"]) {
        //not allow it to move
        [self.linearVelocity removeItem:item];
        //not allow it to interact with future blocks
        [self.collision removeItem:item];
        
    }
}

- (void) unmarkAllBlocks
{
    NSArray *blocksOnScreen = [self.collision items];

    for (UIView *block in blocksOnScreen) {
        if(block.layer.sublayers)
        {
            [(CALayer *)block.layer.sublayers[0] removeFromSuperlayer];
        }
        NSLog(@"Block layer %@ sublayers %@", block, block.layer.sublayers);
    }
}

- (NSArray *)checkClosestBlocksToTargetBlock
{
    
    //get the other blocks that have not gone off the screen
    //they should be able to be collided with
    NSArray *blocksOnScreen = [self.collision items];
    
    //get their locations
    
    NSMutableArray *otherBlockLocations = [[NSMutableArray alloc] init];
    for (UIView *block in blocksOnScreen) {
        //compare their locations to the location of the target block
        NSNumber *distanceToTarget = [self findDistanceToTargetWithBlock:block];
        UIColor *team = block.backgroundColor;
        NSDictionary *blockTeamAndDistance = [[NSDictionary alloc] initWithObjectsAndKeys:team, @"team", distanceToTarget, @"distanceToTarget", block, @"view", nil];
        
        [otherBlockLocations addObject:blockTeamAndDistance];
    }
    
    //find the closest block(s) by sorting array
    [otherBlockLocations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *block1 = obj1;
        NSDictionary *block2 = obj2;
        
        if ([(NSNumber *)block1[@"distanceToTarget"] floatValue] < [(NSNumber *)block2[@"distanceToTarget"] floatValue])
        {
            return NSOrderedAscending;
        }else if ([(NSNumber *)block1[@"distanceToTarget"] floatValue] > [(NSNumber *)block2[@"distanceToTarget"] floatValue])
        {
            return NSOrderedDescending;
        }else
        {
            return NSOrderedSame;
        }
    }];
    
    //iterate over the array to find the index when the team is different
//    NSLog(@"%@", otherBlockLocations);
    
    
    NSMutableArray *winningBlocks = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [otherBlockLocations count]; i++) {
        NSDictionary *currentBlock = otherBlockLocations[i];
        UIView *currentView = currentBlock[@"view"];
        
        
        if (i == 0) {
            [winningBlocks addObject:currentBlock];
        } else if (currentView.backgroundColor == ((UIView *)((NSDictionary *)winningBlocks[0])[@"view"]).backgroundColor ) {
            [winningBlocks addObject:currentBlock];
        } else {
            //stop looking
            i = [otherBlockLocations count];
        }
    }
    
    NSLog(@"winning blocks %@", winningBlocks);
    
    return winningBlocks;
}

- (void)markWinningBlocksWithBlocks:(NSArray *)blocks
{
    if ([blocks count] > 0) {
        
        NSDictionary *winningBlock = blocks[0];
        CGRect superViewBounds = ((UIView *)winningBlock[@"view"]).bounds;
        
        for (NSDictionary *block in blocks) {
            //add a CALayer inside the winning blocks that is yellow.
            CALayer *yellowSquare = [[CALayer alloc]init];
            yellowSquare.backgroundColor = [UIColor yellowColor].CGColor;
            yellowSquare.bounds = CGRectMake(0, 0, superViewBounds.size.width/2, superViewBounds.size.height/2);
            yellowSquare.position = CGPointMake(superViewBounds.size.width/2, superViewBounds.size.height/2);
            
            UIView *view = block[@"view"];
            [view.layer addSublayer:yellowSquare];
        }
    }
    
}

- (NSNumber *)findDistanceToTargetWithBlock:(UIView *)block
{
    //find location of the target block
    CGPoint targetLocation = self.targetBlock.center;
    
    CGPoint blockLocation = block.center;
    
    CGFloat distance = sqrtf(powf((targetLocation.x - blockLocation.x), 2) + powf((targetLocation.y - blockLocation.y), 2));
    
    return [NSNumber numberWithFloat:distance];
}








@end
