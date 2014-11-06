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
    
    //make a green start pad to show where you have to release the box
    CALayer *green = [[CALayer alloc] init];
    green.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150);
    green.backgroundColor = [[UIColor greenColor] CGColor];
    green.zPosition = -1;
    
    [self.view.layer addSublayer:green];
    
    
    //when a thing is dragged, it will have the linearVelocity at the end of the swipe with value average over the pan.
    
    UIPanGestureRecognizer *dragBlueView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    UIPanGestureRecognizer *dragRedView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    
    [self.blueView addGestureRecognizer:dragBlueView];
    [self.redView addGestureRecognizer:dragRedView];
    
    
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.redView,self.blueView]];
    [collision setTranslatesReferenceBoundsIntoBoundary:YES];
    [collision setCollisionMode:UICollisionBehaviorModeEverything];
    
    [self.animator addBehavior:collision];
    
    self.linearVelocity = [[UIDynamicItemBehavior alloc] initWithItems:@[self.blueView,self.redView]];
    
    
    self.linearVelocity.elasticity = 1;
    self.linearVelocity.resistance = 2;
    self.linearVelocity.angularResistance = 2;
    
    [self.animator addBehavior:self.linearVelocity];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
