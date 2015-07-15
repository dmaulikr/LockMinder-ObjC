//
//  LMImagePreviewViewController.h
//  LockMinder
//
//  Created by Nealon Young on 6/29/14.
//  Copyright (c) 2014 Nealon Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMImagePreviewViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property IBOutlet UIImageView *imageView;
@property (nonatomic) UIImage *backgroundImage;
@property (nonatomic) NSArray *reminders;

@end
