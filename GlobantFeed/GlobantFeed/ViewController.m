//
//  ViewController.m
//  GlobantFeed
//
//  Created by Marcelo Taborga on 2/17/14.
//  Copyright (c) 2014 Globant. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController ()
{
    NSDictionary *tweets;
    OAToken *accessToken;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getRequestToken];
    [[self tableViewTweet] setHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)loadButtonsForPin
{
    //text field
    self.pinField = [[UITextField alloc] initWithFrame:CGRectMake(80, 150, 200, 30)];
    [[self pinField] setBackgroundColor:[UIColor whiteColor]];
    [[self pinField] setBorderStyle:UITextBorderStyleLine];
    
    //button
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(10, 150, 50, 30);
    [nextBtn setBackgroundColor:[UIColor blackColor]];
    nextBtn.titleLabel.text = @"set pin";
    nextBtn.titleLabel.textColor = [UIColor blackColor];
    [nextBtn setTitle:@"Pin" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    self.buttonPin = nextBtn;
    
    //adding views to the main view
    [[self view] addSubview:[self pinField]];
    [[self view] addSubview:[self buttonPin]];
    
    
}

-(void)nextPage
{
    [self removeButtonsFromTheView];
    [[self pinField] resignFirstResponder];
    [self getAccessToken];
}

- (void)removeButtonsFromTheView
{
    [[self pinField] setHidden:YES];
    [[self buttonPin] setHidden:YES];
    [[self tableViewTweet] setHidden:NO];
}

- (void)fetchTweets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: @"https://api.twitter.com/1.1/search/tweets.json?q=%23freebandnames&since_id=24012619984051000&max_id=250126199840518145&result_type=mixed&count=4"]];
   
        NSError* error;
      //  https://api.twitter.com/1.1/statuses/home_timeline.json
        if(data){
        tweets = [NSJSONSerialization JSONObjectWithData:data
                                                 options:kNilOptions
                                                   error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.tableView reloadData];
           // [[self view] ]
            [[self tableViewTweet] reloadData];
            
        });
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *status = tweets?[tweets objectForKey:@"statuses"]:Nil;
    return status?status.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *allTweetsForHashTag = [tweets objectForKey:@"statuses"];
    NSDictionary *tweet = [allTweetsForHashTag objectAtIndex:[indexPath row]];
    NSString *text = [tweet objectForKey:@"text"];
    
   NSString *name = [[tweet objectForKey:@"user"] objectForKey:@"name"];//[[tweet objectForKey:@"user"] objectForKey:@"name"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", name];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *allTweetsForHashTag = [tweets objectForKey:@"statuses"];
    NSDictionary *tweet = [allTweetsForHashTag objectAtIndex:[indexPath row]];
    NSString *text = [tweet objectForKey:@"text"];
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey: NSFontAttributeName];

    
    CGRect sizeText = [text boundingRectWithSize:CGSizeMake(320, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil];
  //  CGRect nameRect =
    
    return sizeText.size.height + 35;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTweet"]) {
        
        NSInteger row = [[self tableViewTweet].indexPathForSelectedRow row];
        NSArray *allTweetsForHashTag = [tweets objectForKey:@"statuses"];
        NSDictionary *tweet = [allTweetsForHashTag objectAtIndex:row];
        
        DetailViewController *detailController = segue.destinationViewController;
        detailController.detailItem = tweet;
    }
}


- (void) getRequestToken
{
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"1eSalYH1WDUYDOqFfgye1w"
													secret:@"tUyReZfnvvcu6zEizwDDIuu9TuXo439JcjLuFlx0vY"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:nil
																	  realm:nil
														  signatureProvider:nil];
	
	[request setHTTPMethod:@"POST"];
	
	NSLog(@"Getting request token...");
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
        [self loadButtonsForPin];
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
		NSLog(@"Got request token. Redirecting to twitter auth page...");
		
		NSString *address = [NSString stringWithFormat:
							 @"https://api.twitter.com/oauth/authorize?oauth_token=%@",
							 accessToken.key];
		
		NSURL *url = [NSURL URLWithString:address];
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting request token failed: %@", [error localizedDescription]);
}


- (void) getAccessToken
{
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"1eSalYH1WDUYDOqFfgye1w"
													secret:@"tUyReZfnvvcu6zEizwDDIuu9TuXo439JcjLuFlx0vY"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
	
	[accessToken setVerifier:[[self pinField] text]];
	NSLog(@"Using PIN %@", accessToken.verifier);
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:accessToken
																	  realm:nil
														  signatureProvider:nil];
	
	[request setHTTPMethod:@"POST"];
	
	NSLog(@"Getting access token...");
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		[self getHomeTimeline];
		NSLog(@"Got access token. Ready to use Twitter API.");
	}
}

- (void) accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting access token failed: %@", [error localizedDescription]);
}

- (void) getHomeTimeline
{
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"1eSalYH1WDUYDOqFfgye1w"
													secret:@"tUyReZfnvvcu6zEizwDDIuu9TuXo439JcjLuFlx0vY"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	//h
    
    //https://api.twitter.com/1.1/statuses/home_timeline.json
	NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json?q=%23MWG14&count=4"];
    
//    https://api.twitter.com/1.1/search/tweets.json?q=%40twitterapi
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:accessToken
																	  realm:nil
														  signatureProvider:nil];
	
	NSLog(@"Getting home timeline...");
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(apiTicket:didFinishWithData:)
				  didFailSelector:@selector(apiTicket:didFailWithError:)];
}

- (void) apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	if (ticket.didSucceed)
	{
		if(data){
            NSError* error;
            tweets = [NSJSONSerialization JSONObjectWithData:data
                                                     options:kNilOptions
                                                       error:&error];
            
            [[self tableViewTweet] reloadData];
           
        }
	}
}

- (void) apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	NSLog(@"Getting home timeline failed: %@", [error localizedDescription]);
}



@end




