//
//  SMBookStoreViewController.m
//  Newsstand
//
//  Created by Suleyman Melikoglu on 07/11/13.
//  Copyright (c) 2013 ZulaMobile. All rights reserved.
//

#import "SMBookStoreViewController.h"
#import <RoboReader/RoboReader.h>
#import "UIImageView+WebCache.h"

#import "SMBookStore.h"
#import "SMIssue.h"
#import "SMBookShelfCell.h"
#import "SMBookShelfLayout.h"
#import "SMBookStoreContainer.h"


static NSString *BookStoreCellIdentifier = @"BookStoreCellIdentifier";

@interface SMBookStoreViewController () <UICollectionViewDataSource, UICollectionViewDelegate, RoboViewControllerDelegate, UIGestureRecognizerDelegate, SMBookShelfLayoutDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIToolbar *toolBar;

- (void)startEditMode;
- (void)endEditMode;
- (void)removeItems;
- (void)askToRemoveItems;
- (void)deviceOrientationDidChange:(NSNotification *)notification;
@end

@implementation SMBookStoreViewController
{
    UICollectionViewFlowLayout *layout;
    RoboViewController *pdfCtrl;
    BOOL isEditModeActive;
    dispatch_queue_t queue;
}
@synthesize bookStore, collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        queue = dispatch_queue_create("Book Store Queue", NULL);
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [super loadView];
    
    // our custom shelf layout
    layout = [[SMBookShelfLayout alloc] init];
    
    float minusHeight = 0.0f; //(self.tabBarController) ? 54.0f : 0.0f;
    
    // collection view setup
    self.collectionView =
    [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - minusHeight)
                       collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    self.collectionView.backgroundColor = [UIColor whiteColor]; // [UIColor colorWithPatternImage:[UIImage imageNamed:@"NewsletterDefault.bundle/book-shelf/table-background"]];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // register the custom shelf item
    [self.collectionView registerClass:[SMBookShelfCell class] forCellWithReuseIdentifier:BookStoreCellIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    // orientation notifiers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup toolbar
    CGRect frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 64, [[UIScreen mainScreen] bounds].size.width, 44);
    self.toolBar = [[UIToolbar alloc] initWithFrame:frame];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                target:self
                                                                                action:@selector(askToRemoveItems)];
    [self.toolBar setItems:@[deleteItem] animated:YES];
    self.toolBar.hidden = YES;
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.toolBar];
    
    // enter view mode
    [self endEditMode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // I don't remember what this was
    // @todo
    UIView *aView = [UIView new];
    [self.collectionView addSubview:aView];
}

#pragma mark - overridden methods

- (void)fetchContents
{
    [super fetchContents];
    
    if (![self.componentDesciption hasDownloadableContents]) {
        __block id weakSelf = self;
        dispatch_async(queue, ^{
            SMBookStoreViewController *strongSelf = weakSelf;
            
            // the contents are ready
            strongSelf.bookStore = [[SMBookStoreContainer sharedObject] bookStoreForKey:strongSelf.componentDesciption.title];
            if (!strongSelf.bookStore) {
                strongSelf.bookStore = [[SMBookStore alloc] initWithAttributes:strongSelf.componentDesciption.contents];
                [[SMBookStoreContainer sharedObject] addBookStore:strongSelf.bookStore forKey:strongSelf.componentDesciption.title];
                
                // refresh contents
                [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            }
            
            // mark the first book as the newsletter cover
            if ([strongSelf.bookStore.issues count] > 0) {
                SMIssue *issue = [strongSelf.bookStore.issues objectAtIndex:0];
                if (issue) {
                    [issue setNewsstandIconFromCoverImage];
                }
            }
            
            [strongSelf performSelectorOnMainThread:@selector(applyContents) withObject:Nil waitUntilDone:YES];
        });
        
        return;
    }
    
    // there is downloadable contents, let's fetch them.
    [SMBookStore fetchWithURLString:self.componentDesciption.contents completion:^(SMBookStore *aBookStore, SMServerError *error) {
        if (error) {
            NSLog(@"Content page fetch contents error|%@", [error description]);
            
            // show error
            [self displayErrorString:error.localizedDescription];
            
            return;
        }
        
        self.bookStore = aBookStore;
        [[SMBookStoreContainer sharedObject] addBookStore:self.bookStore forKey:self.componentDesciption.title];
        
        // mark the first book as the newsletter cover
        if ([self.bookStore.issues count] > 0) {
            SMIssue *issue = [self.bookStore.issues objectAtIndex:0];
            if (issue) {
                [issue setNewsstandIconFromCoverImage];
            }
        }
        
        [self applyContents];
    }];
}

- (void)applyContents
{
    if (self.bookStore.backgroundImageUrl) {
        // set background
        [self.backgroundImageView setImageWithURL:self.bookStore.backgroundImageUrl];
    } else if (self.backgroundImageView) {
        // unset background
        [self.backgroundImageView setImage:nil];
    }
    
    // add navigation image if set
    [self applyNavbarIconWithUrl:self.bookStore.navbarIcon];
    
    /*
    dataSource = [[SMArrayDataSource alloc] initWithItems:self.bookStore.issues
                                           cellIdentifier:BookStoreCellIdentifier
                                       configureCellBlock:^(id aCell, id item, NSIndexPath *indexPath)
    {
        SMBookShelfCell *cell = (SMBookShelfCell *)aCell;
        NSInteger perPage = 4;
        NSInteger pageNumber = [indexPath row]%perPage + 1; // index path rows are zero indexed
        NSArray *issuesToDisplay = [self.bookStore issuesForPageNumber:pageNumber ofPerPage:perPage];
        [cell configureWithIssues:issuesToDisplay];
    } itemDidSelectBlock:^(id item) {
        //
    }];
     */
    
    [super applyContents];
}

#pragma mark - collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.bookStore.issues count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SMBookShelfCell *cell =
    (SMBookShelfCell *)[aCollectionView dequeueReusableCellWithReuseIdentifier:BookStoreCellIdentifier
                                                                  forIndexPath:indexPath];
    
    // get the issue for the cell
    SMIssue *issue = [self.bookStore.issues objectAtIndex:[indexPath row]];
    issue.downloadProgressBlock = cell.downloadProgressBlock;
    issue.downloadCompletionBlock = cell.downloadCompletionBlock;
    
    // configure the cell
    cell.label.text = issue.title;
    [cell.coverImage setImageWithURL:issue.coverUrl];
    
    [cell changeState:issue.state];
    
    return cell;
}

#pragma mark - collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return YES;
}

- (void)collectionView:(UICollectionView *)aCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //SMBookShelfCell *cell = (SMBookShelfCell *)[aCollectionView cellForItemAtIndexPath:indexPath];
    SMIssue *issue = [self.bookStore.issues objectAtIndex:[indexPath row]];
    
    if (isEditModeActive) {
        // pause downloads
        for (SMIssue *issue in self.bookStore.issues) {
            if (issue.state == SMIssueIsDownloading) {
                [issue pauseDownload];
            }
        }
        
        // mark/unmark issue
        if (issue.state == SMIssueMarked) {
            issue.state = SMIssueDefault;
        } else {
            issue.state = SMIssueMarked;
        }
    } else {
        // not in edit mode
        if (issue.state == SMIssueAvailable) {
            // show the reader and display the issue
            RoboDocument *document = [[RoboDocument alloc] initWithFilePath:[issue localFilePath] password:nil];
            pdfCtrl = [[RoboViewController alloc] initWithRoboDocument:document];
            pdfCtrl.delegate = self;
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            if (self.tabBarController) {
                [self presentViewController:pdfCtrl animated:YES completion:nil];
            } else {
                [self.navigationController pushViewController:pdfCtrl animated:YES];
            }
        } else {
            // check if available for download
            if (![issue isDownloadUrlValid]) {
                [self displayErrorString:NSLocalizedString(@"This issue cannot be downloaded, Please try again later.", Nil)];
                return;
            }
            
            if (issue.state == SMIssueIsDownloading) {
                // pause
                [issue pauseDownload];
            } else if (issue.state == SMIssuePaused) {
                // resume
                [issue resumeDownload];
            } else {
                // download the issue
                [issue download];
            }
        }
    }
    
    [aCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    SMBookShelfLayout *theLayout = (SMBookShelfLayout *)self.collectionView.collectionViewLayout;
    [theLayout invalidateLayout];
}

- (void)collectionView:(UICollectionView *)aCollectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - robo reader delegate

- (void)dismissRoboViewController:(__unused RoboViewController *)viewController {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.tabBarController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - private methods

// edit mode is started by edit button on navigation bar
- (void)startEditMode
{
    isEditModeActive = YES;
    SMBookShelfLayout *theLayout = (SMBookShelfLayout *)self.collectionView.collectionViewLayout;
    [theLayout invalidateLayout];
    [self.collectionView reloadData];
    
    // buttons
    UIBarButtonItem *endEditModeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(endEditMode)];
    self.navigationItem.rightBarButtonItems = @[endEditModeItem];
    
    // display a toolbar with remove button
    self.toolBar.hidden = NO;
}

// edit mode ends by the done button on navigation bar
- (void)endEditMode
{
    for (SMIssue *issue in self.bookStore.issues) {
        [issue resetState];
    }
    
    isEditModeActive = NO;
    SMBookShelfLayout *theLayout = (SMBookShelfLayout *)self.collectionView.collectionViewLayout;
    [theLayout invalidateLayout];
    [self.collectionView reloadData];
    
    // buttons
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                          target:self
                                                                                          action:@selector(startEditMode)]];
    
    self.toolBar.hidden = YES;
    
}

- (void)askToRemoveItems
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                message:NSLocalizedString(@"Are you sure to remove downloaded data of selected issues?", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles:NSLocalizedString(@"Delete", nil), nil] show];
    
}

- (void)removeItems
{
    for (SMIssue *issue in self.bookStore.issues) {
        if (issue.state == SMIssueMarked) {
            [issue removeFromFilesystem];
            issue.state = SMIssueDefault;
        }
    }
    
    // refresh items
    [self.collectionView reloadData];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    SMBookShelfLayout *theLayout = (SMBookShelfLayout *)self.collectionView.collectionViewLayout;
    [theLayout invalidateLayout];
    [self.collectionView reloadData];
}

#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeItems];
        [self endEditMode];
    }
}

#pragma mark - book shelf layout delegate

- (BOOL)isEditModeActiveForCollectionView:(__unused UICollectionView *)collectionView layout:(__unused SMBookShelfLayout *)layout
{
    return isEditModeActive;
}

@end
