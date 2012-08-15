//
//  ANPostLabel.m
//  AppApp
//
//  Created by brandon on 8/14/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostLabel.h"

@implementation ANPostLabel
{
    NSString *_postText;
}

static NSArray *expressions = nil;

+ (void)initialize
{
	// setup regular expressions that define where buttons will be created
	expressions = [[NSArray alloc] initWithObjects:
                   @"(\\+)?([0-9]{8,}+)", // phone numbers, 8 or more
                   @"(@[a-zA-Z0-9_]+)", // screen names
                   @"(#[a-zA-Z0-9_-]+)", // hash tags
                   @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])", // hyperlinks with http://
                   @"[wW][wW][wW].([a-z]|[A-Z]|[0-9]|[/.]|[~])*", // hyperlinks like www.something.tld
                   nil];
}

- (void)setPostText:(NSString *)thePostText
{
    NSString *text = thePostText;
    
    // keep an array of already parsed substrings of the current line of text
    // (if we get more than 16 matches this is going to crash)
    NSRange parsedRanges[16];
    NSInteger parsedRangesLength = 0;
    
    // take each of the regular expressions that we defined and try to match it within the text
	for (NSString *expression in expressions)
	{
		NSString *match;
		NSEnumerator *enumerator = [text matchEnumeratorWithRegex:expression];
        
        // go through all the matches and weed out overlapping ones in the process
		while (match = [enumerator nextObject])
		{
            // compute the size of the matched string
			CGSize matchSize = [match sizeWithFont:font];
            
            NSRange matchRange;
            NSInteger startingLocation = 0;
            BOOL matchAlreadyHandled = NO;
            
            // in a gist, the while below will keep trying to match a substring if it hasn't been matched yet
            // this prevents double-matching an url like www.a.com if http://www.a.com was already matched
            // this also allows the engine to match a string like 'www.a.com www.a.com'
            while (true) {
                // find the first match in our text
                matchRange = [text rangeOfString:match options:0 range:NSMakeRange(startingLocation, [text length] - startingLocation)];
                
                // check if the match's range overlaps any of the previously handled matches
                BOOL isOverlapping = NO;
                for (int i=0; i < parsedRangesLength; i++)
                {
                    NSRange aRange = parsedRanges[i];
                    if (NSIntersectionRange(aRange, matchRange).length != 0)
                    {
                        // the match overlaps, therefore move the caret to the right
                        startingLocation = matchRange.location + matchRange.length;
                        isOverlapping = YES;
                        break;
                    }
                }
                if (isOverlapping)
                {
                    if (startingLocation >= [text length])
                    {
                        // we are at the end of our string therefore we have exhausted all chances to match it
                        matchAlreadyHandled = YES;
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
            if (matchAlreadyHandled)
            {
                continue;
            }
			
			NSRange measureRange = NSMakeRange(0, matchRange.location);
            // take the string that precedes the match
			NSString *measureText = [text substringWithRange:measureRange];
            // compute the size of the string that precedes the match
			CGSize measureSize = [measureText sizeWithFont:font];
			
            // compute the frame of the matched text
			CGRect matchFrame = CGRectMake(measureSize.width - 3.0f, point.y, matchSize.width + 6.0f, matchSize.height);
			[self createButtonWithText:match withFrame:matchFrame];
			
            parsedRanges[parsedRangesLength] = matchRange;
            parsedRangesLength++;
			//NSLog(@"match = %@", match);
		}
	}
}

@end
