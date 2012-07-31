/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameLayer.h"

@interface GameLayer (PrivateMethods)
@end

// Velocity deceleration
const float deceleration = 0.4f;
// Accelerometer sensitivity (higher = more sensitive)
const float sensitivity = 6.0f;
// Maximum velocity
const float maxVelocity = 100.0f;

@implementation GameLayer

-(id) init
{
	if ((self = [super init]))
	{
        // Enable accelerometer input events.
		[KKInput sharedInput].accelerometerActive = YES;
		[KKInput sharedInput].acceleration.filteringFactor = 0.2f;
        // Graphic for player
        player = [CCSprite spriteWithFile:@"green_ball.png"];
		[self addChild:player z:0 tag:1];
        // Position player        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = [player texture].contentSize.height;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		glClearColor(0.1f, 0.1f, 0.3f, 1.0f);
		// First line of title
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Kobold2d Intro Tutorial" 
                                               fontName:@"Arial"  
                                               fontSize:30];
		label.position = [CCDirector sharedDirector].screenCenter;
		label.color = ccCYAN;
        [self addChild:label];
        // Second line of title
 		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Lesson 1"
                                                fontName:@"Arial"
                                                fontSize:24];
		label2.color = ccCYAN;
        label2.position = CGPointMake([CCDirector sharedDirector].screenCenter.x ,label.position.y - label.boundingBox.size.height);
        [self addChild:label2];
        // Start animation -  the update method is called.
        [self scheduleUpdate];;
	}
	return self;
}

#pragma mark Player Movement
-(void) acceleratePlayerWithX:(double)xAcceleration
{
    // Adjust velocity based on current accelerometer acceleration
    playerVelocity.x = (playerVelocity.x * deceleration) + (xAcceleration * sensitivity);
    // Limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    if (playerVelocity.x > maxVelocity)
    {
        playerVelocity.x = maxVelocity;
    }
    else if (playerVelocity.x < -maxVelocity)
    {
        playerVelocity.x = -maxVelocity;
    }
}

-(void) acceleratePlayerWithY:(double)yAcceleration
{
    // Adjust velocity based on current accelerometer acceleration
    playerVelocity.y = (playerVelocity.y * deceleration) + (yAcceleration * sensitivity);
    // Limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    if (playerVelocity.y > maxVelocity)
    {
        playerVelocity.y = maxVelocity;
    }
    else if (playerVelocity.y < -maxVelocity)
    {
        playerVelocity.y = -maxVelocity;
    }
}
#pragma mark update
-(void) update:(ccTime)delta
{
    // Gain access to the user input devices / states
    KKInput* input = [KKInput sharedInput];
    [self acceleratePlayerWithX:input.acceleration.smoothedX];
    [self acceleratePlayerWithY:input.acceleration.smoothedY];
    // Accumulate up the playerVelocity to the player's position
    CGPoint pos = player.position;
    pos.x += playerVelocity.x;
    pos.y += playerVelocity.y;
    // The player constrainted to inside the screen
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    // Half the player image size player sprite position is the center of the image
    float imageWidthHalved = [player texture].contentSize.width * 0.5f;
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    
    float imageHeightHalved = [player texture].contentSize.height * 0.5f;
    float bottomBorderLimit = imageHeightHalved;
    float topBorderLimit = screenSize.height - imageHeightHalved;
    // Hit left boundary
    if (pos.x < leftBorderLimit)
    {
        pos.x = leftBorderLimit;
        // Set velocity to zero
        playerVelocity.x = CGPointZero.x;
    }
    // Hit right boundary
    else if (pos.x > rightBorderLimit)
    {
        pos.x = rightBorderLimit;
        // Set velocity to zero
        playerVelocity.x = CGPointZero.x;
    }
    
    //Hit bottom boundary
    if (pos.y < bottomBorderLimit)
    {
        pos.y = bottomBorderLimit;
        // Set velocity to zero
        playerVelocity.y = CGPointZero.y;
    }
    
    //Hit top boundary
    else if (pos.y > topBorderLimit)
    {
        pos.y = topBorderLimit;
        // Set velocity to zero
        playerVelocity.y = CGPointZero.y;
    }
    // Move the player
    player.position = pos; 
}  


@end
