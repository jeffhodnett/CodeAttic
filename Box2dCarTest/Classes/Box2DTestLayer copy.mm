//
//  Box2DTestLayer.mm
//  CarTest
//
//  Created by Jeff Hodnett on 14/09/2010.
//  Copyright 2010 Acrossair. All rights reserved.
//

#import "Box2DTestLayer.h"


@implementation Box2DTestLayer

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

enum {
	kTagTileMap = 1,
	kTagSpriteManager = 1,
	kTagAnimation1 = 1,
};


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Box2DTestLayer *layer = [Box2DTestLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
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
		
		//Set up sprite
		
		//AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"blocks.png" capacity:150];
		//[self addChild:mgr z:0 tag:kTagSpriteManager];
		
		[self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
		
		[self schedule: @selector(tick:)];
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
	// define our body
	b2BodyDef bodyDef;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	//	bodyDef.userData = sprite;
	bodyDef.linearDamping = 1;
	bodyDef.angularDamping = 1;
	body = world->CreateBody(&bodyDef);
//	body->SetMassFromShapes();
	
	// Front Wheels
	// Left
	b2BodyDef leftWheelDef;
	leftWheelDef.position.Set(p.x/PTM_RATIO-1.1f, p.y/PTM_RATIO-1.80f);
	leftWheel = world->CreateBody(&leftWheelDef);
	// Right
	b2BodyDef rightWheelDef;
	rightWheelDef.position.Set(p.x/PTM_RATIO+1.1f, p.y/PTM_RATIO-1.8f);
	rightWheel = world->CreateBody(&rightWheelDef);
	
	// Back Wheels
	// Left
	b2BodyDef leftRearWheelDef;
	leftRearWheelDef.position.Set(p.x/PTM_RATIO-1.1f, p.y/PTM_RATIO+1.8f);
	leftRearWheel = world->CreateBody(&leftRearWheelDef);
	// Right
	b2BodyDef rightRearWheelDef;
	rightRearWheelDef.position.Set(p.x/PTM_RATIO+1.1f, p.y/PTM_RATIO+1.8f);
	rightRearWheel = world->CreateBody(&rightRearWheelDef);
	
	// define our shapes
	b2PolygonShape boxDef;
	boxDef.SetAsBox(1.0f,2.0f);
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &boxDef;
	fixtureDef.density = 1.0F;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
//	body->SetMassFromShapes();
	
	//Left Front Wheel shape
	b2PolygonShape leftWheelShapeDef;
	leftWheelShapeDef.SetAsBox(0.2f,0.5f);
	b2FixtureDef fixtureDefLeftWheel;
	fixtureDefLeftWheel.shape = &leftWheelShapeDef;
	fixtureDefLeftWheel.density = 1.0F;
	fixtureDefLeftWheel.friction = 0.3f;
	leftWheel->CreateFixture(&fixtureDefLeftWheel);
//	leftWheel->SetMassFromShapes();
	
	//Right Front Wheel shape
	b2PolygonShape rightWheelShapeDef;
	rightWheelShapeDef.SetAsBox(0.2f,0.5f);
	b2FixtureDef fixtureDefRightWheel;
	fixtureDefRightWheel.shape = &rightWheelShapeDef;
	fixtureDefRightWheel.density = 1.0F;
	fixtureDefRightWheel.friction = 0.3f;
	rightWheel->CreateFixture(&fixtureDefRightWheel);
//	rightWheel->SetMassFromShapes();
	
	//Left Back Wheel shape
	b2PolygonShape leftRearWheelShapeDef;
	leftRearWheelShapeDef.SetAsBox(0.2f,0.5f);
	b2FixtureDef fixtureDefLeftRearWheel;
	fixtureDefLeftRearWheel.shape = &leftRearWheelShapeDef;
	fixtureDefLeftRearWheel.density = 1.0F;
	fixtureDefLeftRearWheel.friction = 0.3f;
	leftRearWheel->CreateFixture(&fixtureDefLeftRearWheel);
//	leftRearWheel->SetMassFromShapes();
	
	//Right Back Wheel shape
	b2PolygonShape rightRearWheelShapeDef;
	rightRearWheelShapeDef.SetAsBox(0.2f,0.5f);
	b2FixtureDef fixtureDefRightRearWheel;
	fixtureDefRightRearWheel.shape = &rightRearWheelShapeDef;
	fixtureDefRightRearWheel.density = 1.0F;
	fixtureDefRightRearWheel.friction = 0.3f;
	rightRearWheel->CreateFixture(&fixtureDefRightRearWheel);
//	rightRearWheel->SetMassFromShapes();
	
	b2RevoluteJointDef leftJointDef;
	leftJointDef.Initialize(body, leftWheel, leftWheel->GetWorldCenter());
	leftJointDef.enableMotor = true;
	leftJointDef.maxMotorTorque = 10.0;
	
	b2RevoluteJointDef rightJointDef;
	rightJointDef.Initialize(body, rightWheel, rightWheel->GetWorldCenter());
	rightJointDef.enableMotor = true;
	rightJointDef.maxMotorTorque = 10.0;
	
	leftJoint = (b2RevoluteJoint *) world->CreateJoint(&leftJointDef);
	rightJoint = (b2RevoluteJoint *) world->CreateJoint(&rightJointDef);
	
	b2Vec2 wheelAngle;
	wheelAngle.Set(1,0);
	
	// Join back wheels
	// Left
	b2PrismaticJointDef leftRearJointDef;
	leftRearJointDef.Initialize(body, leftRearWheel, leftRearWheel->GetWorldCenter(),wheelAngle);
//	leftRearJointDef.enableLimit = true;
	leftRearJointDef.enableLimit = NO;
	leftRearJointDef.lowerTranslation = 0;
	leftRearJointDef.upperTranslation = 0;
	world->CreateJoint(&leftRearJointDef);
	// Right
	b2PrismaticJointDef rightRearJointDef;
	rightRearJointDef.Initialize(body, rightRearWheel, rightRearWheel->GetWorldCenter(),wheelAngle);
	rightRearJointDef.enableLimit = true;
	rightRearJointDef.lowerTranslation = 0;
	rightRearJointDef.upperTranslation = 0;
	world->CreateJoint(&rightRearJointDef);
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
	
	/*[self killOrthogonalVelocityForTarget:leftWheel];
	[self killOrthogonalVelocityForTarget:rightWheel];
	[self killOrthogonalVelocityForTarget:leftRearWheel];
	[self killOrthogonalVelocityForTarget:rightRearWheel];
	*/
	
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
	NSLog(@"mspeed %f",mspeed);
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

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"TOUCHES STARTED");
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		if (location.x > 160.0F)
			steeringAngle = 1.03F;
		else
			steeringAngle = -1.03F;
		if (location.y > 160.0F)
			engineSpeed = -40;
		else
			engineSpeed = +40;
	
		NSLog(@"steeringAngle %f engineSpeed %f",steeringAngle,engineSpeed);

	}
}

@end