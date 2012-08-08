//
//  Ball.m
//  accelTest
//
//  Created by Matt on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

@implementation Ball

const float DEFAULT_MASS=10;
const float DEFAULT_FRICTION=1;
const float DEFAULT_MAX_SPEED=100;

@synthesize mass;
@synthesize maxSpeed;
@synthesize velocity;


+(id)ballWithMass:(float)m speed:(float)s
{
    Ball *b=nil;
    if ((b = [[super alloc] initWithFile:@"green_ball.png"]))
    {
        b.mass = m;
        b.maxSpeed=s;
    }
    return b;
    
}
@end