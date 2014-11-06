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
    
    //make a green start pad to show where you have to release the box
    CALayer *green = [[CALayer alloc] init];
    green.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150);
    green.backgroundColor = [[UIColor greenColor] CGColor];
    green.zPosition = -1;
    [self.view.layer addSublayer:green];
    
    //init collision behavior
    self.collision = [[UICollisionBehavior alloc] init];
    [self.collision setTranslatesReferenceBoundsIntoBoundary:YES];
    [self.collision setCollisionMode:UICollisionBehaviorModeEverything];
    [self.animator addBehavior:self.collision];
    
    //init linearVelocity
    self.linearVelocity = [[UIDynamicItemBehavior alloc] init];
    self.linearVelocity.elasticity = 0.4;
    self.linearVelocity.resistance = 2;
    self.linearVelocity.angularResistance = 2;
    
    //make block
    [self makeBlockWithColor:[UIColor blackColor]];
}

- (void) makeBlockWithColor:(UIColor *)color
{
    //init block
    self.currentBlock = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2- 15, self.view.frame.size.height - 60, 30, 30)];
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
                    
                }else if ([gesture velocityInView:self.view].y < 0){
                    
                    CGPoint velocity = [gesture velocityInView:self.view];
                    NSLog(@"%f %f",[gesture velocityInView:self.view].x, [gesture velocityInView:self.view].y);
                    
                    [self.linearVelocity addLinearVelocity:velocity forItem:gesture.view];
                    [self.animator addBehavior:self.linearVelocity];
                    [self.animator updateItemUsingCurrentState:gesture.view];
                    
                    [gesture.view setUserInteractionEnabled:NO];
                    
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
    if (self.justMadeBlock) {
        self.justMadeBlock = NO;
    }
    else if (self.blocksMade % 2 == 1)
    {
        if (self.currentBlock.backgroundColor == [UIColor blackColor]) {
            [self.collision removeItem:self.currentBlock];
//            [self.collision setCollisionMode:UICollisionBehaviorModeItems];
        }
        [self makeBlockWithColor:[UIColor redColor]];
    }else if (self.blocksMade % 2 == 0)
    {
        [self makeBlockWithColor:[UIColor blueColor]];
    }
    
}


@end
