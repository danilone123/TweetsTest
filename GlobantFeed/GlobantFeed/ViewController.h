//
//  ViewController.h
//  GlobantFeed
//
//  Created by Marcelo Taborga on 2/17/14.
//  Copyright (c) 2014 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthConsumer.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    
}

@property(nonatomic,weak)IBOutlet UITableView *tableViewTweet;
@property (nonatomic,strong)  UIButton *buttonPin;
@property (nonatomic, strong)  UITextField *pinField;
- (void)fetchTweets;
@end
