//
//  LMListViewController.m
//  LockMinder
//
//  Created by Nealon Young on 6/28/14.
//  Copyright (c) 2014 Nealon Young. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "LMListViewController.h"
#import "LMImageGenerator.h"
#import "LMImagePreviewViewController.h"
#import "ReminderCell.h"
#import "SVProgressHUD.h"

@interface LMListViewController () <UITableViewDataSource, UITableViewDelegate>

@property EKEventStore *eventStore;
@property NSMutableArray *reminders;
@property NSMutableArray *selectedReminders;
@property IBOutlet UITableView *tableView;

- (void)importReminders;

@end

@implementation LMListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eventStore = [[EKEventStore alloc] init];
    [self importReminders];
}

- (void)importReminders {
    [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"You must grant access to reminders to use LockMinder", nil)];
            return;
        }
        
        EKCalendar *defaultReminderCalendar = self.eventStore.defaultCalendarForNewReminders;
        NSPredicate *completedRemindersPredicate = [self.eventStore predicateForIncompleteRemindersWithDueDateStarting:nil
                                                                                                                ending:nil
                                                                                                             calendars:@[defaultReminderCalendar]];
        
        [self.eventStore fetchRemindersMatchingPredicate:completedRemindersPredicate completion:^(NSArray *reminders) {
            self.reminders = [reminders mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (![self.reminders count]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Select at least one reminder", nil)];
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSMutableArray *remindersToShow;
    
    // If the user has not selected any reminders, use all incomplete reminders
    // Otherwise, use only the selected reminders
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    if ([selectedIndexPaths count]) {
        remindersToShow = [NSMutableArray array];
        
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            [remindersToShow addObject:self.reminders[indexPath.row]];
        }
    } else {
        remindersToShow = self.reminders;
    }
    
    LMImagePreviewViewController *previewViewController = (LMImagePreviewViewController *)segue.destinationViewController;
    
    // Access the view controller's view property to instantiate the image view
    [previewViewController view];
    
    previewViewController.reminders = remindersToShow;
    previewViewController.backgroundImage = [UIImage imageNamed:@"Wallpaper"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self.reminders count]) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.backgroundColor = [UIColor whiteColor];
    }
    
    return [self.reminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReminderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell" forIndexPath:indexPath];
    cell.reminderLabel.font = [UIFont applicationFontOfSize:18.0f];
    EKReminder *reminder = self.reminders[indexPath.row];
    cell.reminderLabel.text = reminder.title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    EKReminder *reminder = self.reminders[sourceIndexPath.row];
    [self.reminders removeObjectAtIndex:sourceIndexPath.row];
    [self.reminders insertObject:reminder atIndex:destinationIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.reminders count]) {
        return 44.0f;
    } else {
        return 120.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectZero];
    headerView.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
    headerView.font = [UIFont applicationFontOfSize:15.0f];
    headerView.textAlignment = NSTextAlignmentCenter;
    
    if ([self.reminders count]) {
        headerView.text = NSLocalizedString(@"Select reminders to appear on your wallpaper", nil);
    } else {
        headerView.text = NSLocalizedString(@"No reminders", nil);
    }
    
    return headerView;
}

@end
