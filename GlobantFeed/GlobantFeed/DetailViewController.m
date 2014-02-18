//
//  DetailViewController.m
//  GlobantFeed
//
//  Created by Marcelo Taborga on 2/18/14.
//  Copyright (c) 2014 Globant. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)configureView
{
    if (self.detailItem) {
        NSDictionary *tweet = self.detailItem;
        
        NSString *text = [[tweet objectForKey:@"user"] objectForKey:@"name"];
        NSString *name = [tweet objectForKey:@"text"];
        
       // self.TweetContent.lineBreakMode = uili;
        self.TweetContent.numberOfLines = 0;
        
        self.NameUser.text = text;
        self.TweetContent.text = name;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageTweet.image = [UIImage imageWithData:data];
            });
        });
        
       
    }
}


@end
