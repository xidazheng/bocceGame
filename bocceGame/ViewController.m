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
@property (nonatomic) BOOL justMadeBlock;
@property (nonatomic) BOOL notSuccessfullyThrown;

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
    self.notSuccessfullyThrown = NO;
    
    //make a green start pad to show where you have to release the box
    CALayer *green = [[CALayer alloc] init];
    green.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150);
    green.backgroundColor = [[UIColor greenColor] CGColor];
    green.zPosition = -1;
    [self.view.layer addSublayer:green];
    
    //init collision behavior
    self.collision = [[UICollisionBehavior alloc] init];
    self.collision.collisionDelegate = self;
    [self.collision setTranslatesReferenceBoundsIntoBoundary:YES];
    [self.collision setCollisionMode:UICollisionBehaviorModeEverything];
    
    //add initial boundary for jack (the target ball)
    [self.collision addBoundaryWithIdentifier:@"end" fromPoint:CGPointMake(0, self.view.frame.size.height*0.1) toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height*0.1)];

    
    [self.animator addBehavior:self.collision];
    
    
    
    
    //init linearVelocity
    self.linearVelocity = [[UIDynamicItemBehavior alloc] init];
    self.linearVelocity.elasticity = 0.05;
    self.linearVelocity.resistance = 4;
    self.linearVelocity.angularResistance = 4;
    
    //make block
    [self makeBlockWithColor:[UIColor blackColor]];
}

- (void) makeBlockWithColor:(UIColor *)color
{
    //init block
    self.currentBlock = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- 22.5, self.view.frame.size.height - 60, 45, 45)];
    self.currentBlock.backgroundColor = color;
    [self.view addSubview:self.currentBlock];
    
    //place block
    
    
    //add draggable behavior, only one object should have draggable behavior and it should be reassigned when a new block is created
    UIPanGestureRecognizer *draggable = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    
    [self.currentBlock addGestureRecognizer:draggable];
    [self.collision addItem:self.currentBlock];
    [self.linearVelocity addItem:self.currentBlock];
    
    self.blocksMade++;
    self.justMadeBlock = YES;
}
//get the delegate for the animation and when the animation is done make the next block


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
                
                if (newY < self.view.frame.size.height - 150) {
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
                
                
                if (endY < self.view.frame.size.height - 150) {
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
    else if (self.blocksMade % 2 == 1)
    {
        if (self.currentBlock.backgroundColor == [UIColor blackColor]) {
            //check that the ball is within the target range and reset if not
            
            
            self.targetBlock = self.currentBlock;
            [self.collision removeItem:self.currentBlock];
            [self.collision removeBoundaryWithIdentifier:@"end"];
            [self.collision setTranslatesReferenceBoundsIntoBoundary:NO];
//            [self.collision addBoundaryWithIdentifier:@"box" fromPoint:CGPointMake(0, self.view.frame.size.height*0.05) toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height*0.05)];
            [self.collision addBoundaryWithIdentifier:@"outOfBounds" forPath:[UIBezierPath bezierPathWithRect:CGRectMake(-90, -90, self.view.frame.size.width+180, self.view.frame.size.height+180)]];
        }
        
        [self unmarkAllBlocks];
        NSArray *blocks = [self checkClosestBlocksToTargetBlock];
        [self markWinningBlocksWithBlocks:blocks];
        
        [self makeBlockWithColor:[UIColor redColor]];
    }else if (self.blocksMade % 2 == 0)
    {
        
        [self unmarkAllBlocks];
        NSArray *blocks = [self checkClosestBlocksToTargetBlock];
        [self markWinningBlocksWithBlocks:blocks];
        
        [self makeBlockWithColor:[UIColor blueColor]];
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if ([((NSString *)identifier) isEqualToString:@"outOfBounds"]) {
        //stop the motion
//        CGPoint linearVelocity = [self.linearVelocity linearVelocityForItem:item];
//        CGPoint inverseLinearVelocity = CGPointMake(-linearVelocity.x, -linearVelocity.y);
//        [self.linearVelocity addLinearVelocity:inverseLinearVelocity forItem:item];
        
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
