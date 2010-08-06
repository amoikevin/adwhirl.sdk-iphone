//---------------------------------------------------------------------------------------
//  $Id: OCMBlockCaller.h 57 2010-07-19 06:14:27Z erik $
//  Copyright (c) 2010 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

#if NS_BLOCKS_AVAILABLE

@interface OCMBlockCaller : NSObject 
{
	void (^block)(NSInvocation *);
}

-(id)initWithCallBlock:(void (^)(NSInvocation *))theBlock;

@end

#endif
