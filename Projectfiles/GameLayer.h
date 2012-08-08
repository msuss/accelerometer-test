/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "kobold2d.h"
#import "Ball.h"

@interface GameLayer : CCLayer
{
    Ball *player;
    NSMutableArray *balls;
    CGPoint playerVelocity;
}

@end
