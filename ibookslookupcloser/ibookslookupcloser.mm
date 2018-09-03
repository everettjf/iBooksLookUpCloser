//
//  ibookslookupcloser.mm
//  ibookslookupcloser
//
//  Created by everettjf on 2018/9/2.
//  Copyright (c) 2018 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CaptainHook/CaptainHook.h"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

static const char * kCloseButton;

@class DDParsecCollectionViewController;
@interface DDParsecCollectionViewController : UIViewController
- (void)doneButtonPressed:(id)arg1;
@end

@interface DDParsecCollectionViewController (ibookslookupcloser)
@property (nonatomic, strong) UIButton * eveCloseButton;
@end
@implementation DDParsecCollectionViewController (ibookslookupcloser)

- (void)setEveCloseButton:(UIButton *)button{
    objc_setAssociatedObject(self, &kCloseButton, button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)eveCloseButton{
    return objc_getAssociatedObject(self, &kCloseButton);
}

- (void)eveCloseButtonTapped:(id)event{
    NSLog(@"qiwei: DDParsecCollectionViewController close button tapped");
    [self doneButtonPressed:event];
}


@end


CHDeclareClass(DDParsecCollectionViewController); // declare class

CHOptimizedMethod(1, self, void, DDParsecCollectionViewController, viewWillAppear,BOOL,value1) // hook method (with no arguments and no return value)
{
    NSLog(@"qiwei: DDParsecCollectionViewController will appear");
    if(self.eveCloseButton == nil){
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        const NSUInteger kWidth = 80;
        self.eveCloseButton = [[UIButton alloc] initWithFrame: CGRectMake(0, screenSize.height - kWidth, kWidth, kWidth)];
        self.eveCloseButton.backgroundColor = [UIColor clearColor];
        [self.eveCloseButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.eveCloseButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.eveCloseButton addTarget:self action:@selector(eveCloseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.eveCloseButton];
    }

	CHSuper(1, DDParsecCollectionViewController, viewWillAppear, value1); // call old (original) method
}

CHConstructor // code block that runs immediately upon load
{
	@autoreleasepool
	{
        CHLoadLateClass(DDParsecCollectionViewController);  // load class (that will be "available later")
		CHHook(1, DDParsecCollectionViewController, viewWillAppear); // register hook
	}
}
