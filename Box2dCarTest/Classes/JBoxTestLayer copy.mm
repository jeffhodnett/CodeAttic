//
//  JBoxTestLayer.m
//  CarTest
//
//  Created by Jeff Hodnett on 15/09/2010.
//  Copyright 2010 Acrossair. All rights reserved.
//

#import "JBoxTestLayer.h"

#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "SneakyJoystickSkinnedJoystickExample.h"
#import "ColoredCircleSprite.h"

@implementation JBoxTestLayer

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

enum {
	kTagTileMap = 1,
	kTagSpriteManager = 1,
	kTagAnimation1 = 1,
	kTagJoystick = 4
};


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	JBoxTestLayer *layer = [JBoxTestLayer node];
	
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
				
		[self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
//		[self newAddSprite:ccp(screenSize.width/2, screenSize.height/2)];
		
		[self schedule: @selector(tick:)];
//		[self schedule: @selector(newTick:)];
		
		[self createJoystickWithData];
		
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

-(void)newAddSprite:(CGPoint)p {
	// ---- TEST ---
	/*b2Body* ground = NULL;
	{
		b2BodyDef bd;
		ground = world->CreateBody(&bd);
		
		b2PolygonShape shape;
		shape.SetAsEdge(b2Vec2(50.0f, 10.0f), b2Vec2(-50.0f, 10.0f));
		ground->CreateFixture(&shape, 0.0f);
	}*/
	
	{
		// define our body
		b2BodyDef bodyDef;
		bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
		//	bodyDef.userData = sprite;
		bodyDef.linearDamping = 1;
		bodyDef.angularDamping = 1;
		body = world->CreateBody(&bodyDef);	
	}
	
	{
		// CIRCLE
		b2CircleShape circle1;
		circle1.m_radius = 1.0f;
		
		b2BodyDef bd1;
		bd1.type = b2_dynamicBody;
		bd1.position.Set(7.0f, 7.0f);
		b2Body* body1 = world->CreateBody(&bd1);
		body1->CreateFixture(&circle1, 5.0f);
		
		b2RevoluteJointDef jd1;
		jd1.bodyA = body;//ground;
		jd1.bodyB = body1;
//		jd1.localAnchorA = ground->GetLocalPoint(bd1.position);
		jd1.localAnchorA = body->GetLocalPoint(bd1.position);
		jd1.localAnchorB = body1->GetLocalPoint(bd1.position);
//		jd1.referenceAngle = body1->GetAngle() - ground->GetAngle();
		jd1.referenceAngle = body1->GetAngle() - body->GetAngle();
		jd1.enableMotor = true;
		jd1.motorSpeed = 0.0f;
		jd1.maxMotorTorque = 70000.f;
		
		m_joint1 = (b2RevoluteJoint*)world->CreateJoint(&jd1);
		
		// BOX
		b2PolygonShape box;
		box.SetAsBox(0.5f, 1.0f);
		
		b2BodyDef bd3;
		bd3.type = b2_dynamicBody;
		bd3.position.Set(2.5f, 7.0f);
		b2Body* body3 = world->CreateBody(&bd3);
		body3->CreateFixture(&box, 5.0f);
		
		b2PrismaticJointDef jd3;
//		jd3.Initialize(ground, body3, bd3.position, b2Vec2(0.0f, 1.0f));
		jd3.Initialize(body, body3, bd3.position, b2Vec2(0.0f, 1.0f));
		jd3.lowerTranslation = -5.0f;
		jd3.upperTranslation = 5.0f;
		jd3.enableLimit = true;
		
		m_joint3 = (b2PrismaticJoint*)world->CreateJoint(&jd3);
		
/*		b2GearJointDef jd4;
		jd4.bodyA = body1;
		jd4.bodyB = body2;
		jd4.joint1 = m_joint1;
		jd4.joint2 = m_joint2;
		jd4.ratio = circle2.m_radius / circle1.m_radius;
		m_joint4 = (b2GearJoint*)world->CreateJoint(&jd4);
		
		b2GearJointDef jd5;
		jd5.bodyA = body2;
		jd5.bodyB = body3;
		jd5.joint1 = m_joint2;
		jd5.joint2 = m_joint3;
		jd5.ratio = -1.0f / circle2.m_radius;
		m_joint5 = (b2GearJoint*)world->CreateJoint(&jd5);
 */
		
		// Left
		b2BodyDef leftWheelDef;
		leftWheelDef.type = b2_dynamicBody;
		leftWheelDef.position.Set(p.x/PTM_RATIO-1.1f, p.y/PTM_RATIO-1.80f);
		leftWheel = world->CreateBody(&leftWheelDef);
		
		//Left Front Wheel shape
		b2PolygonShape leftWheelShapeDef;
		leftWheelShapeDef.SetAsBox(0.2f,0.5f);
		b2FixtureDef fixtureDefLeftWheel;
		fixtureDefLeftWheel.shape = &leftWheelShapeDef;
		fixtureDefLeftWheel.density = 1.0F;
		fixtureDefLeftWheel.friction = 0.3f;
		leftWheel->CreateFixture(&fixtureDefLeftWheel);
		
		b2RevoluteJointDef leftJointDef;
		leftJointDef.bodyA = body;//ground;
		leftJointDef.bodyB = leftWheel;
		leftJointDef.localAnchorA = body->GetLocalPoint(leftWheelDef.position);
		leftJointDef.localAnchorB = leftWheel->GetLocalPoint(leftWheelDef.position);
		leftJointDef.referenceAngle = leftWheel->GetAngle() - body->GetAngle();
		leftJointDef.enableMotor = true;
		leftJointDef.motorSpeed = 0.0f;
		leftJointDef.maxMotorTorque = 70000.f;
	}	
}

-(void) newTick: (ccTime) dt {
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	m_joint1->SetMotorSpeed(engineSpeed * 1.5F);
	engineSpeed += 0.1;
	
	b2Vec2 ldirection = leftWheel->GetTransform().R.col2;
	ldirection *= engineSpeed;
	leftWheel->ApplyForce(ldirection, leftWheel->GetPosition());

}


-(void) addNewSpriteWithCoords:(CGPoint)p
{
	// define our body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
//	bodyDef.userData = sprite;
	bodyDef.linearDamping = 1;
	bodyDef.angularDamping = 1;
	body = world->CreateBody(&bodyDef);
	
	// Front Wheels
	// Left
	b2BodyDef leftWheelDef;
	leftWheelDef.type = b2_dynamicBody;
	leftWheelDef.position.Set(p.x/PTM_RATIO-1.1f, p.y/PTM_RATIO-1.80f);
	leftWheel = world->CreateBody(&leftWheelDef);
	
	// Right
	b2BodyDef rightWheelDef;
	rightWheelDef.type = b2_dynamicBody;
	 rightWheelDef.position.Set(p.x/PTM_RATIO+1.1f, p.y/PTM_RATIO-1.8f);
	 rightWheel = world->CreateBody(&rightWheelDef);
	 
	 // Back Wheels
	 // Left
	 b2BodyDef leftRearWheelDef;
	leftRearWheelDef.type = b2_dynamicBody;
	 leftRearWheelDef.position.Set(p.x/PTM_RATIO-1.1f, p.y/PTM_RATIO+1.8f);
	 leftRearWheel = world->CreateBody(&leftRearWheelDef);
	 // Right
	 b2BodyDef rightRearWheelDef;
	rightRearWheelDef.type = b2_dynamicBody;
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

	//Left Front Wheel shape
	b2PolygonShape leftWheelShapeDef;
	leftWheelShapeDef.SetAsBox(0.2f,0.5f);
	b2FixtureDef fixtureDefLeftWheel;
	fixtureDefLeftWheel.shape = &leftWheelShapeDef;
	fixtureDefLeftWheel.density = 1.0F;
	fixtureDefLeftWheel.friction = 0.3f;
	leftWheel->CreateFixture(&fixtureDefLeftWheel);
	
	//Right Front Wheel shape
	b2PolygonShape rightWheelShapeDef;
	 rightWheelShapeDef.SetAsBox(0.2f,0.5f);
	 b2FixtureDef fixtureDefRightWheel;
	 fixtureDefRightWheel.shape = &rightWheelShapeDef;
	 fixtureDefRightWheel.density = 1.0F;
	 fixtureDefRightWheel.friction = 0.3f;
	 rightWheel->CreateFixture(&fixtureDefRightWheel);
	 
	 //Left Back Wheel shape
	 b2PolygonShape leftRearWheelShapeDef;
	 leftRearWheelShapeDef.SetAsBox(0.2f,0.5f);
	 b2FixtureDef fixtureDefLeftRearWheel;
	 fixtureDefLeftRearWheel.shape = &leftRearWheelShapeDef;
	 fixtureDefLeftRearWheel.density = 1.0F;
	 fixtureDefLeftRearWheel.friction = 0.3f;
	 leftRearWheel->CreateFixture(&fixtureDefLeftRearWheel);
	 
	 //Right Back Wheel shape
	 b2PolygonShape rightRearWheelShapeDef;
	 rightRearWheelShapeDef.SetAsBox(0.2f,0.5f);
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
	leftJointDef.maxMotorTorque = 10000.f;
	
	 b2RevoluteJointDef rightJointDef;
	 rightJointDef.Initialize(body, rightWheel, rightWheel->GetWorldCenter());
	 rightJointDef.enableMotor = true;
	 rightJointDef.motorSpeed = 0.0f;
	 rightJointDef.maxMotorTorque = 10000.f;

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
	/*for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	 {
	 if (b->GetUserData() != NULL) {
	 //Synchronize the AtlasSprites position and rotation with the corresponding body
	 CCSprite* myActor = (CCSprite*)b->GetUserData();
	 myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
	 myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
	 }
	 }*/
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	/*NSLog(@"TOUCHES STARTED");
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
		
	}*/
}

#pragma mark Joystick
-(void)createJoystickWithData {
	
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
	if(scaledVelocity.x != 0.0 && scaledVelocity.y != 0.0) {
		
		if(scaledVelocity.x > 0) {
			steeringAngle = 1.03F;
		}
		else {
			steeringAngle = -1.03F;
		}
		
		if(scaledVelocity.y > 0) {
//			engineSpeed = -40;
			engineSpeed = -10;
		}
		else {
//			engineSpeed = 40;
			engineSpeed = 10;
		}
		
		/*for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
			if (b->GetUserData() != NULL) {
				b->SetLinearVelocity(b2Vec2(scaledVelocity.x,scaledVelocity.y));
			}
		}*/
	}
}

@end
