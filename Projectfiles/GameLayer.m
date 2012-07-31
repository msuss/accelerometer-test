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

const float scaleFactor=1.0f;

BOOL velocityMode=YES;

@implementation GameLayer

-(id) init
{
	if ((self = [super init]))
	{
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(50, 100, 200, 100)];
        [self addChild:colorLayer z:10 tag:0];
        
        CCMenuItemFont *orangeButton=[CCMenuItemFont itemFromString:@"Orange"
                                 block:
         ^(id sender){[self changeBackgroundColor:ccc4(255, 127, 0, 100)];}];
        
         CCMenuItemFont *blueButton=[CCMenuItemFont itemFromString:@"Blue" 
                                  block:
          ^(id sender){[self changeBackgroundColor:ccc4(0, 0, 255, 100)];}];
        
         CCMenuItemFont *greenButton=[CCMenuItemFont itemFromString:@"Green" 
                                  block:
          ^(id sender){[self changeBackgroundColor:ccc4(0, 255, 0, 100)];}];
        
        CCMenu *itemMenu=[CCMenu menuWithItems:orangeButton, blueButton, greenButton, nil];
        [itemMenu setPosition:ccp(50, 200)];
        [itemMenu alignItemsVerticallyWithPadding:60];
        [self addChild:itemMenu z:1 tag:2];
        
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
		//glClearColor(0.1f, 0.1f, 0.3f, 1.0f);

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
#pragma mark-
#pragma mark BackgroundColoring
-(void) changeBackgroundColor: (ccColor4B) color
{
    [self removeChildByTag:0 cleanup:YES];
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:color];
    [self addChild:colorLayer z:10 tag:0];
    
    
}

-(void) changeBackgroundByDelta: (int) delta
{
    CCLayerColor* colorLayer=(CCLayerColor *)[self getChildByTag:0];
    ccColor3B color=colorLayer.color;
    int r=color.r+delta*scaleFactor;
    int g=color.g+delta*scaleFactor;
    int b=color.b+delta*scaleFactor;
    if (r>255) r=255;
    if (r<0) r=0;
    if (g>255) g=255;
    if (g<0) g=0;
    if (b>255) b=255;
    if (b<0) b=0;
    [self changeBackgroundColor: ccc4(r,g,b, [colorLayer opacity])];
}

-(void) changeBackgroundByVelocityX: (float) x y: (float) y
{
    CCLayerColor* colorLayer=(CCLayerColor *)[self getChildByTag:0];
    ccColor3B color=colorLayer.color;
    int r=color.r+x*scaleFactor;
    int g=color.g+y*scaleFactor;
    int b=color.b+(x+y)/2*scaleFactor;
    if (r>255) r=255;
    if (r<0) r=0;
    if (g>255) g=255;
    if (g<0) g=0;
    if (b>255) b=255;
    if (b<0) b=0;
    [self changeBackgroundColor: ccc4(r,g,b, [colorLayer opacity])];
}

#pragma mark-
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
    if (velocityMode)
    {
        [self changeBackgroundByVelocityX:playerVelocity.x y:playerVelocity.y];
    } 
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
