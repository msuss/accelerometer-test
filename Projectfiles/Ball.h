//
//  Ball.h
//  accelTest
//
//  Created by Matt on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"

@interface Ball : CCSprite
{
    float mass;
    float maxSpeed;
    CGPoint velocity;

}

@property float mass;
@property float maxSpeed;
@property CGPoint velocity;

+(id) ballWithMass:(float)m speed:(float)s;

@end