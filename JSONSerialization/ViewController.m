//
//  ViewController.m
//  JSONSerialization
//
//  Created by Avigit Saha on 2015-05-06.
//  Copyright (c) 2015 Avigit Saha. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
//	NSString *json = @"{\"Name\":\"avigit\", \"Company\":[{\"Name\":\"GB\", \"Address\":\"Research Dr\"},{\"Name\":\"iQmetrix\", \"Address\":\"Cornowall\"}]}";
//	
//	Person *person = [[Person alloc] initWithJSONData:[json dataUsingEncoding:NSUTF8StringEncoding]];
	
//	_name.text = person.name;
//	_company.text = [NSString stringWithFormat:@"%@, %@", person.company.name, person.company.address];
	
//	NSLog(@"%@", [person JSONString]);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
