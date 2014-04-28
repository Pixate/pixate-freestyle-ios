//
//  CustomButtonViewController.m
//  UINavigationBar
//
//  Created by Paul Colton on 3/10/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "CustomButtonViewController.h"
#import "PixateFreestyle.h"

@interface CustomButtonViewController ()
{
    UIButton *myButton;
}
@end

@implementation CustomButtonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    myButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 100, 35);
    [myButton setTitle:@"Cancel" forState:UIControlStateNormal];
    myButton.styleClass = @"cancelButton";
    [myButton addTarget:self action:@selector(handleEmail) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)handleEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.navigationBar.styleId = @"mailer";
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"My subject..."];
        [mailer setToRecipients:@[ @"paul@pixate.com"]];
        NSString *emailBody = [NSString stringWithFormat:@"This is a test"];
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Your device doesn't seem to be configured for email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Could not send the email."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
			break;
        }
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}



@end
