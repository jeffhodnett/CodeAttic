//
//  JHBox2DLayer.m
//  CarTest
//
//  Created by Jeff Hodnett on 25/09/2010.
//  Copyright 2010 Applausible. All rights reserved.
//

#import "JHBox2DLayer.h"

#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "SneakyJoystickSkinnedJoystickExample.h"
#import "ColoredCircleSprite.h"

@implementation JHBox2DLayer

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

enum {
	kTagBackground = 1,
	kTagSprite = 2,
	kTagJoystick = 4
};


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	JHBox2DLayer *layer = [JHBox2DLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
				
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// car control
		engineSpeed = 0;
		steeringAngle = 0;
		
		// Do we want to let bodies sleep?
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
		flags += b2DebugDraw::e_aabbBit;
		flags += b2DebugDraw::e_pairBit;
		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;			
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
				
		// Add our logo! yes i know it's shameful plugging, but makes for a nice screenshot
		CCSprite *bg = [CCSprite spriteWithFile:@"app_logo.png"];
		[bg setTag:kTagBackground];
		bg.position = ccp(screenSize.width/2,screenSize.height/2);
		[self addChild:bg];
		
		// Add a car sprite
		[self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
		
		// Add a joystick
		[self createJoystick];
		
		// Schedule a tick for the scene
		[self schedule: @selector(tick:)];
		
		// Add a toggle menu item to show and hide the car sprite
		CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(carSpriteCallback:) items:
								   [CCMenuItemFont itemFromString: @"Off"],
								   [CCMenuItemFont itemFromString: @"On"],
								   nil];
		CCMenu *menu = [CCMenu menuWithItems:item1, nil];
		menu.position = ccp(screenSize.width - 20, 20);
		[self addChild:menu];
		
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	
	[super dealloc];
}	

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
}

-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCSprite *car = [[CCSprite alloc] initWithFile:@"car_small.png"];
	car.position = ccp(p.x, p.y);
	[car setTag:kTagSprite];
	[self addChild:car];
	[car release];
	
	// define our body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = car;
	bodyDef.linearDamping = 1;
	bodyDef.angularDamping = 1;
	body = world->CreateBody(&bodyDef);
	
	float boxW = 0.3f;
	float boxH = 0.7f;
	float wheelW = 0.08f;
	float wheelH = 0.2f;
	float wheelX = 0.35f;
	float wheelY = 0.35f;
	
	// Front Wheels
	// Left
	b2BodyDef leftWheelDef;
	leftWheelDef.type = b2_dynamicBody;
	leftWheelDef.position.Set(p.x/PTM_RATIO-wheelX, p.y/PTM_RATIO-wheelY);
	leftWheel = world->CreateBody(&leftWheelDef);
	
	// Right
	b2BodyDef rightWheelDef;
	rightWheelDef.type = b2_dynamicBody;
	 rightWheelDef.position.Set(p.x/PTM_RATIO+wheelX, p.y/PTM_RATIO-wheelY);
	 rightWheel = world->CreateBody(&rightWheelDef);
	 
	 // Back Wheels
	 // Left
	 b2BodyDef leftRearWheelDef;
	leftRearWheelDef.type = b2_dynamicBody;
	 leftRearWheelDef.position.Set(p.x/PTM_RATIO-wheelX, p.y/PTM_RATIO+wheelY);
	 leftRearWheel = world->CreateBody(&leftRearWheelDef);
	 // Right
	 b2BodyDef rightRearWheelDef;
	rightRearWheelDef.type = b2_dynamicBody;
	 rightRearWheelDef.position.Set(p.x/PTM_RATIO+wheelX, p.y/PTM_RATIO+wheelY);
	 rightRearWheel = world->CreateBody(&rightRearWheelDef);
	 
	 // define our shapes
	 b2PolygonShape boxDef;
	 boxDef.SetAsBox(boxW,boxH);
	 b2FixtureDef fixtureDef;
	 fixtureDef.shape = &boxDef;
	 fixtureDef.density = 1.0F;
	 fixtureDef.friction = 0.3f;
	 body->CreateFixture(&fixtureDef);

	//Left Front Wheel shape
	b2PolygonShape leftWheelShapeDef;
	leftWheelShapeDef.SetAsBox(wheelW, wheelH);
	b2FixtureDef fixtureDefLeftWheel;
	fixtureDefLeftWheel.shape = &leftWheelShapeDef;
	fixtureDefLeftWheel.density = 1.0F;
	fixtureDefLeftWheel.friction = 0.3f;
	leftWheel->CreateFixture(&fixtureDefLeftWheel);
	
	//Right Front Wheel shape
	b2PolygonShape rightWheelShapeDef;
	 rightWheelShapeDef.SetAsBox(wheelW, wheelH);
	 b2FixtureDef fixtureDefRightWheel;
	 fixtureDefRightWheel.shape = &rightWheelShapeDef;
	 fixtureDefRightWheel.density = 1.0F;
	 fixtureDefRightWheel.friction = 0.3f;
	 rightWheel->CreateFixture(&fixtureDefRightWheel);
	 
	 //Left Back Wheel shape
	 b2PolygonShape leftRearWheelShapeDef;
	 leftRearWheelShapeDef.SetAsBox(wheelW, wheelH);
	 b2FixtureDef fixtureDefLeftRearWheel;
	 fixtureDefLeftRearWheel.shape = &leftRearWheelShapeDef;
	 fixtureDefLeftRearWheel.density = 1.0F;
	 fixtureDefLeftRearWheel.friction = 0.3f;
	 leftRearWheel->CreateFixture(&fixtureDefLeftRearWheel);
	 
	 //Right Back Wheel shape
	 b2PolygonShape rightRearWheelShapeDef;
	 rightRearWheelShapeDef.SetAsBox(wheelW, wheelH);
	 b2FixtureDef fixtureDefRightRearWheel;
	 fixtureDefRightRearWheel.shape = &rightRearWheelShapeDef;
	 fixtureDefRightRearWheel.density = 1.0F;
	 fixtureDefRightRearWheel.friction = 0.3f;
	 rightRearWheel->CreateFixture(&fixtureDefRightRearWheel);
	 
	 // ------ JOINTS ---------

	b2RevoluteJointDef leftJointDef;
	leftJointDef.Initialize(body, leftWheel, leftWheel->GetWorldCenter());
	leftJointDef.enableMotor = true;
	leftJointDef.motorSpeed = 0.0f;
	leftJointDef.maxMotorTorque = 1000.f;
	
	 b2RevoluteJointDef rightJointDef;
	 rightJointDef.Initialize(body, rightWheel, rightWheel->GetWorldCenter());
	 rightJointDef.enableMotor = true;
	 rightJointDef.motorSpeed = 0.0f;
	 rightJointDef.maxMotorTorque = 1000.f;

	leftJoint = (b2RevoluteJoint *) world->CreateJoint(&leftJointDef);
	rightJoint = (b2RevoluteJoint *) world->CreateJoint(&rightJointDef);

	b2Vec2 wheelAngle;
	wheelAngle.Set(1,0);
	
	 // Join back wheels
	 // Left
	 b2PrismaticJointDef leftRearJointDef;
	 leftRearJointDef.Initialize(body, leftRearWheel, leftRearWheel->GetWorldCenter(),wheelAngle);
	 leftRearJointDef.enableLimit = true;
	 leftRearJointDef.lowerTranslation = 0.0f;
	 leftRearJointDef.upperTranslation = 0.0f;
	(b2PrismaticJoint*) world->CreateJoint(&leftRearJointDef);
	 // Right
	 b2PrismaticJointDef rightRearJointDef;
	 rightRearJointDef.Initialize(body, rightRearWheel, rightRearWheel->GetWorldCenter(),wheelAngle);
	 rightRearJointDef.enableLimit = true;
	 rightRearJointDef.lowerTranslation = 0.0f;
	 rightRearJointDef.upperTranslation = 0.0f;
	 (b2PrismaticJoint*)world->CreateJoint(&rightRearJointDef);
}

-(void) killOrthogonalVelocityForTarget:(b2Body *)targetBody
{
	b2Vec2 localPoint;
	localPoint.Set(0,0);
	b2Vec2 velocity = targetBody->GetLinearVelocityFromLocalPoint(localPoint);
	
	b2Vec2 sidewaysAxis = targetBody->GetTransform().R.col2;
	sidewaysAxis *= b2Dot(velocity,sidewaysAxis);
	
	targetBody->SetLinearVelocity(sidewaysAxis);
	//targetBody.GetWorldPoint(localPoint));
}

-(void) tick: (ccTime) dt
{	
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
		
	//rightWheel->ApplyTorque(500);
	//leftWheel->ApplyTorque(500);
	 
	 [self killOrthogonalVelocityForTarget:leftWheel];
	 [self killOrthogonalVelocityForTarget:rightWheel];
	 [self killOrthogonalVelocityForTarget:leftRearWheel];
	 [self killOrthogonalVelocityForTarget:rightRearWheel];
	 
	 //Driving
	 b2Vec2 localPoint;
	 localPoint.Set(0,0);
	 b2Vec2 ldirection = leftWheel->GetTransform().R.col2;
	 ldirection *= engineSpeed;
	 b2Vec2 rdirection = rightWheel->GetTransform().R.col2;
	 rdirection *= engineSpeed;
	 leftWheel->ApplyForce(ldirection, leftWheel->GetPosition());
	 rightWheel->ApplyForce(rdirection, rightWheel->GetPosition());
	 
	 //Steering
	 float mspeed = steeringAngle - leftJoint->GetJointAngle();
	 leftJoint->SetMotorSpeed(mspeed * 1.5F);
	 mspeed = steeringAngle - rightJoint->GetJointAngle();
	 rightJoint->SetMotorSpeed(mspeed * 1.5F);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	 {
		 if (b->GetUserData() != NULL) {
			 //Synchronize the AtlasSprites position and rotation with the corresponding body
			 CCSprite* myActor = (CCSprite*)b->GetUserData();
			 myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			 myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		 }
	 }
}

#pragma mark Joystick
-(void)createJoystick {
	
	// Create the joystick object
	SneakyJoystickSkinnedBase *leftJoy = [[[SneakyJoystickSkinnedBase alloc] init] autorelease];
	leftJoy.position = ccp(64,250);
	leftJoy.backgroundSprite = [ColoredCircleSprite circleWithColor:ccc4(255, 0, 0, 128) radius:64];
	leftJoy.thumbSprite = [ColoredCircleSprite circleWithColor:ccc4(0, 0, 255, 200) radius:32];
	leftJoy.joystick = [[SneakyJoystick alloc] initWithRect:CGRectMake(0,0,128,128)];
	[self addChild:leftJoy z:3 tag:kTagJoystick];
	
	[self schedule:@selector(joystickTick:) interval:1.0f/120.0f];
}

-(void) joystickTick: (ccTime) dt {
	
	// Apply the joystick movement
	SneakyJoystickSkinnedBase *joy = (SneakyJoystickSkinnedBase *)[self getChildByTag:kTagJoystick];
	CGPoint scaledVelocity = ccpMult(joy.joystick.velocity, 480.0f / 50); 
	
	// Move it if possible	
	if(scaledVelocity.x == 0) {
		steeringAngle = 0.0;
	}
	else if(scaledVelocity.x > 0) {
		steeringAngle = 1.03F;
	}
	else {
		steeringAngle = -1.03F;
	}
	
	if(scaledVelocity.y > 0) {
		engineSpeed = -2;

	}
	else {
		//engineSpeed = 10;
	}
}

#pragma mark Toggle callback
-(void)carSpriteCallback:(id)sender {
	
	CCSprite *bg = (CCSprite *)[self getChildByTag:kTagBackground];
	CCSprite *car = (CCSprite *)[self getChildByTag:kTagSprite];
	
	if([sender selectedIndex] != 0) {
		bg.opacity = 0.0;
		car.opacity = 0.0;
	}
	else {
		bg.opacity = 255;
		car.opacity = 255;
	}

}

@end
