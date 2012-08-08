/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "Ball.h"

@interface GameLayer (PrivateMethods)
@end

//// Velocity deceleration
//const float deceleration = 0.4f;
//// Accelerometer sensitivity (higher = more sensitive)
//const float sensitivity = 6.0f;
//// Maximum velocity
//const float maxVelocity = 120.0f;

float SCALE_FACTOR=1.0f;
const float MASS_FACTOR=50.0f;
const float FRICTION_FACTOR=.02f;
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
        
        CCMenu *colorMenu=[CCMenu menuWithItems:orangeButton, blueButton, greenButton, nil];
        [colorMenu setPosition:ccp(80, 160)];
        [colorMenu alignItemsVerticallyWithPadding:60];
        [self addChild:colorMenu z:1 tag:2];
        
        CCMenuItemFont *lowButton=[CCMenuItemFont itemFromString:@"Low"
                                                           block:
                                   ^(id sender){SCALE_FACTOR=.5f;}];
        
        CCMenuItemFont *medButton=[CCMenuItemFont itemFromString:@"Med" 
                                                           block:
                                   ^(id sender){SCALE_FACTOR=1.0f;}];
        
        CCMenuItemFont *highButton=[CCMenuItemFont itemFromString:@"High" 
                                                            block:
                                    ^(id sender){SCALE_FACTOR=2.0f;}];
        
        CCMenu *sensitivityMenu=[CCMenu menuWithItems:highButton, medButton, lowButton, nil];
        [sensitivityMenu setPosition:ccp(400, 160)];
        [sensitivityMenu alignItemsVerticallyWithPadding:60];
        [self addChild:sensitivityMenu z:1 tag:3];
        
        // Enable accelerometer input events.
		[KKInput sharedInput].accelerometerActive = YES;
		[KKInput sharedInput].acceleration.filteringFactor = 0.2f;
        // Graphic for player
        player = [Ball ballWithMass:10 speed:100];
		[self addChild:player z:0 tag:1];
        // Position player        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = [player texture].contentSize.height;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
        
        //Extra Ball
        Ball *ball1=[Ball ballWithMass:30 speed:100];
        balls=[[NSMutableArray alloc] init];
        [balls addObject:ball1];
        [self addChild:ball1];
        ball1.position=CGPointMake(screenSize.width/2, screenSize.height/2);
        
		//glClearColor(0.1f, 0.1f, 0.3f, 1.0f);
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explo2.wav"];
        
        // Start animation -  the update method is called.
        [self scheduleUpdate];;
	}
	return self;
}

#pragma mark PlayerMovement
-(void) acceleratePlayerWithX:(double)xAcceleration y:(double) yAcceleration
{
    // Adjust velocity based on current accelerometer acceleration
    float deceleration=(player.mass*FRICTION_FACTOR);
    
    playerVelocity.x = (playerVelocity.x -playerVelocity.x*deceleration) + (xAcceleration * MASS_FACTOR/player.mass);
    // Limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    if (playerVelocity.x > player.maxSpeed)
    {
        playerVelocity.x = player.maxSpeed;
    }
    else if (playerVelocity.x < -player.maxSpeed)
    {
        playerVelocity.x = -player.maxSpeed;
    }
    
    // Adjust velocity based on current accelerometer acceleration
    playerVelocity.y = (playerVelocity.y-playerVelocity.y*deceleration) + (yAcceleration * MASS_FACTOR/player.mass);
    // Limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    if (playerVelocity.y > player.maxSpeed)
    {
        playerVelocity.y = player.maxSpeed;
    }
    else if (playerVelocity.y < -player.maxSpeed)
    {
        playerVelocity.y = -player.maxSpeed;
    }
}

#pragma mark-

#pragma mark PlayerMovement
-(void) accelerateBall: (Ball *)ball withX:(double)xAcceleration y:(double) yAcceleration
{
    // Adjust velocity based on current accelerometer acceleration
    float deceleration=(player.mass*FRICTION_FACTOR);
    
    float tempX=(ball.velocity.x -ball.velocity.x*deceleration) + (xAcceleration * MASS_FACTOR/ball.mass);
    float tempY=(ball.velocity.y-ball.velocity.y*deceleration) + (yAcceleration * MASS_FACTOR/ball.mass);
    // Limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    if (tempX> ball.maxSpeed)
    {
        tempX = player.maxSpeed;
    }
    else if (tempX < -ball.maxSpeed)
    {
        tempX = -ball.maxSpeed;
    }
    
    // Limit the maximum velocity of the player sprite, in both directions (positive & negative values)
    if (tempY >ball.maxSpeed)
    {
        tempY= ball.maxSpeed;
    }
    else if (tempY < -ball.maxSpeed)
    {
        tempY = -ball.maxSpeed;
    }
    ball.velocity=ccp(tempX,tempY);
}

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
    int r=color.r+delta*SCALE_FACTOR;
    int g=color.g+delta*SCALE_FACTOR;
    int b=color.b+delta*SCALE_FACTOR;
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
    int r=color.r+x*SCALE_FACTOR;
    int g=color.g+y*SCALE_FACTOR;
    int b=color.b+(x+y)/2*SCALE_FACTOR;
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
    // The player constrainted to inside the screen
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    // Half the player image size player sprite position is the center of the image
    float imageWidthHalved = [player texture].contentSize.width * 0.5f;
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    
    float imageHeightHalved = [player texture].contentSize.height * 0.5f;
    float bottomBorderLimit = imageHeightHalved;
    float topBorderLimit = screenSize.height - imageHeightHalved;
    
    // Gain access to the user input devices / states
    KKInput* input = [KKInput sharedInput];
    [self acceleratePlayerWithX:input.acceleration.smoothedX y:input.acceleration.smoothedY];
    for (Ball *ball in balls)
    {
        [self accelerateBall:ball 
                       withX:input.acceleration.smoothedX 
                           y:input.acceleration.smoothedY];
        float tempX = ball.velocity.x+ball.position.x;
        float tempY = ball.velocity.y+ball.position.y;
        ball.position=ccp(tempX,tempY);        
    }
    // Accumulate up the playerVelocity to the player's position
    
    // Hit left boundary
    
    CGPoint pos = player.position;
    bool xSound=true;
    bool ySound=true;
    if (pos.x==leftBorderLimit||pos.x==rightBorderLimit) xSound=FALSE;
    if (pos.y==topBorderLimit||pos.y==bottomBorderLimit) ySound=FALSE;
    pos.x += playerVelocity.x;
    pos.y += playerVelocity.y;
    if (velocityMode)
    {
        [self changeBackgroundByVelocityX:playerVelocity.x y:playerVelocity.y];
    } 
   
    if (pos.x < leftBorderLimit)
    {
        pos.x = leftBorderLimit;
        // Set velocity to zero
        
        if (xSound)[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
        playerVelocity.x = CGPointZero.x;
    }
    // Hit right boundary
    else if (pos.x > rightBorderLimit)
    {
        pos.x = rightBorderLimit;
        // Set velocity to zero
        if (xSound)[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
        playerVelocity.x = CGPointZero.x;
    }
    
    //Hit bottom boundary
    if (pos.y < bottomBorderLimit)
    {
        pos.y = bottomBorderLimit;
        // Set velocity to zero
        if (ySound)[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
        playerVelocity.y = CGPointZero.y;
    }
    
    //Hit top boundary
    else if (pos.y > topBorderLimit)
    {
        pos.y = topBorderLimit;
        // Set velocity to zero
        if (ySound)[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
        playerVelocity.y = CGPointZero.y;
    }
    // Move the player
    player.position = pos; 
}  


@end