//
//  DetailViewController.h
//  GlobantFeed
//
//  Created by Marcelo Taborga on 2/18/14.
//  Copyright (c) 2014 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *keySecret;
@property (weak, nonatomic) IBOutlet UIImageView *imageTweet;
@property (weak, nonatomic) IBOutlet UILabel *TweetContent;
@property (weak, nonatomic) IBOutlet UILabel *NameUser;

@end
