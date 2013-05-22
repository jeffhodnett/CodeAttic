//
//  JBoxTestLayer.h
//  CarTest
//
//  Created by Jeff Hodnett on 15/09/2010.
//  Copyright 2010 Acrossair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface JBoxTestLayer : CCLayer {
	b2World* world;
	GLESDebugDraw *m_debugDraw;
	b2Body *body;
	b2Body *leftWheel;
	b2Body *rightWheel;
	b2Body *leftRearWheel;
	b2Body *rightRearWheel;
	b2RevoluteJoint * leftJoint;
	b2RevoluteJoint * rightJoint;
	
	b2RevoluteJoint* m_joint1;
	b2RevoluteJoint* m_joint2;
	b2PrismaticJoint* m_joint3;
	b2GearJoint* m_joint4;
	b2GearJoint* m_joint5;
	
	float engineSpeed;
	float steeringAngle;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void) killOrthogonalVelocityForTarget:(b2Body *)targetBody;

@end
