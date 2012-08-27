//
//  MKInfoPanel.m
//  HorizontalMenu
//
//  Created by Mugunth on 25/04/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8e on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices
//
//*** Changes made for AppApp by Jeremy Tregunna, @jtregunna on app.net
//  All code changed clearly marked with @jtregunna. Accounts for 3 lines. Changes were made to facilitate
//  showing the view from the bottom with the transition towards the top, rather than from the top with the
//  transition towards the bottom.

#import "MKInfoPanel.h"
#import <QuartzCore/QuartzCore.h>

// Private Methods

@interface MKInfoPanel ()

@property (nonatomic, assign) MKInfoPanelType type;

+ (MKInfoPanel*) infoPanel;

- (void)setup;

@end


@implementation MKInfoPanel

@synthesize titleLabel = _titleLabel;
@synthesize detailLabel = _detailLabel;
@synthesize thumbImage = _thumbImage;
@synthesize backgroundGradient = _backgroundGradient;
@synthesize onTouched = _onTouched;
@synthesize delegate = _delegate;
@synthesize onFinished = _onFinished;
@synthesize type = type_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_delegate performSelector:_onFinished];
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

-(void)setType:(MKInfoPanelType)type {
    if(type == MKInfoPanelTypeError) {
        self.backgroundGradient.image = [UIImage imageNamed:@"Error Notification BG"];
        self.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:14.0f];
        self.detailLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        self.thumbImage.image = [UIImage imageNamed:@"ErrorNotificationIcon"];
        self.detailLabel.textColor = [UIColor colorWithRed:1.f green:0.651f blue:0.651f alpha:1.f];
    }
    else if(type == MKInfoPanelTypeWarning) {
        self.backgroundGradient.image = [UIImage imageNamed:@"WarningNotificationBG"];
        self.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:14.0f];
        self.detailLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        self.thumbImage.image = [UIImage imageNamed:@"WarningNotificationIcon"];
        self.detailLabel.textColor = [UIColor colorWithHue:0.146 saturation:1.000 brightness:0.416 alpha:1];
    }
    else if(type == MKInfoPanelTypeInfo) {
        //self.backgroundGradient.image = [[UIImage imageNamed:@"Blue"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.backgroundGradient.image = [UIImage imageNamed:@"Success Notification BG"];
        self.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:14.0f];
        self.detailLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        self.thumbImage.image = [UIImage imageNamed:@"SuccessNotificationIcon"];
        self.detailLabel.textColor = RGBA(210, 210, 235, 1.0);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Show/Hide
////////////////////////////////////////////////////////////////////////

+ (MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInView:view type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {    
    MKInfoPanel *panel = [MKInfoPanel infoPanel];
    CGFloat panelHeight = 50;   // panel height when no subtitle set
    UIColor *textColor = nil;
    
    panel.type = type;
    panel.titleLabel.text = title;

    switch(type)
    {
        case MKInfoPanelTypeInfo:
            textColor = [UIColor colorWithHue:0.361 saturation:0.955 brightness:0.349 alpha:1];
            break;
        case MKInfoPanelTypeWarning:
            textColor = [UIColor colorWithHue:0.146 saturation:1.000 brightness:0.416 alpha:1];
            break;
        case MKInfoPanelTypeError:
            textColor = [UIColor colorWithHue:0.976 saturation:0.882 brightness:0.431 alpha:1];
            break;
    }

    panel.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    panel.titleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:14.0f];
    panel.titleLabel.textColor = textColor;
    panel.titleLabel.shadowOffset = CGSizeMake(0, 1);
    panel.detailLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    panel.detailLabel.textColor = textColor;
    panel.detailLabel.shadowOffset = CGSizeMake(0, 1);

    if(subtitle) {
        panel.detailLabel.text = subtitle;
        [panel.detailLabel sizeToFit];
        
        panelHeight = MAX(CGRectGetMaxY(panel.thumbImage.frame), CGRectGetMaxY(panel.detailLabel.frame));
        panelHeight += 10.f;    // padding at bottom
    } else {
        panel.detailLabel.hidden = YES;
        panel.thumbImage.frame = CGRectMake(11, 5, 32, 32);
        panel.titleLabel.frame = CGRectMake(54, 12, 243, 21);
    }

    // update frame of panel
    panel.frame = CGRectMake(CGRectGetMinX(view.bounds), CGRectGetMinY(view.bounds) < 0 ? 0 : CGRectGetMinY(view.bounds), view.bounds.size.width, panelHeight);
    [view addSubview:panel];
    
    if (interval > 0) {
        [panel performSelector:@selector(hidePanel) withObject:view afterDelay:interval]; 
    }
    
    return panel;
}

+ (MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {
    MKInfoPanel *panel = [self showPanelInView:window type:type title:title subtitle:subtitle hideAfter:interval];
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect frame = panel.frame;
        frame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
        panel.frame = frame;
    }
    
    return panel;
}

-(void)hidePanel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromTop; // Changed transition direction due to position change @jtregunna
	[self.layer addAnimation:transition forKey:nil];
    self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Touch Recognition
////////////////////////////////////////////////////////////////////////

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:_onTouched];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

+(MKInfoPanel *)infoPanel {
    MKInfoPanel *panel =  (MKInfoPanel*) [[[UINib nibWithNibName:@"MKInfoPanel" bundle:nil] 
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromBottom; // Changed transition direction due to position change @jtregunna
	[panel.layer addAnimation:transition forKey:nil];
    
    return panel;
}

- (void)setup {
    self.onTouched = @selector(hidePanel);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

@end
