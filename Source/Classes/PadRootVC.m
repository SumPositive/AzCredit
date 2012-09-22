//
//  PadRootVC.m
//  AzPacking
//
//  Created by Sum Positive on 11/05/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppDelegate.h"
#import "PadRootVC.h"
#import "TopMenuTVC.h"


//@interface PadRootVC (PrivateMethods)
//@end


@implementation PadRootVC
@synthesize delegate;
//@synthesize menuPopoverController;


- (void)unloadRelease	// dealloc, viewDidUnload から呼び出される
{
	NSLog(@"--- unloadRelease --- PadRootVC");
}

- (void)dealloc
{
	[self unloadRelease];
    [super dealloc];
}

- (void)viewDidUnload 
{	// メモリ不足時、裏側にある場合に呼び出されるので、viewDidLoadで生成したObjを解放する。
	// メモリ不足時、裏側にある場合に呼び出される。addSubviewされたOBJは、self.viewと同時に解放される
	[super viewDidUnload];  // TableCell破棄される
	[self unloadRelease];		// その後、AdMob破棄する
	//self.splitViewController = nil;
	// この後に loadView ⇒ viewDidLoad ⇒ viewWillAppear がコールされる
}


#pragma mark - Action

- (void)barButtonAdd 
{	// Add Card
	if ([delegate respondsToSelector:@selector(e3detailAdd)]) {	// メソッドの存在を確認する
		[delegate e3detailAdd];
	}
}


#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

// IBを使わずにviewオブジェクトをプログラム上でcreateするときに使う
//（viewDidLoadは、nibファイルでロードされたオブジェクトを初期化するために使う）
- (void)loadView
{
	//AzLOG(@"------- E1viewController: loadView");    
	[super loadView];

	//self.title = NSLocalizedString(@"Product Title",nil);

	self.navigationItem.hidesBackButton = YES;

	self.view.backgroundColor = [UIColor colorWithRed:152/255.0f 
												green:81/255.0f 
												 blue:75/255.0f 
												alpha:1.0f];
	
	//------------------------------------------アイコン
	CGRect rect = self.view.bounds;
	rect.origin.x = rect.size.width/2.0 - 72/2;  //故意に少し左寄せしている
	rect.origin.y = 160;
	rect.size.width = rect.size.height = 72;
	UIImageView *iv = [[UIImageView alloc] initWithFrame:rect];
#ifdef AzSTABLE
	[iv setImage:[UIImage imageNamed:@"Icon72S1.png"]];
#else
	[iv setImage:[UIImage imageNamed:@"Icon72Free.png"]];
#endif
	[self.view addSubview:iv]; 
	[iv release], iv = nil;
	
	// Tool Bar Button
	UIBarButtonItem *buFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			 target:nil action:nil] autorelease];
	UIBarButtonItem *buAdd = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																			target:self action:@selector(barButtonAdd)] autorelease];
#ifdef AzMAKE_SPLASHFACE
	buAdd.enabled = NO;
#endif
	NSArray *buArray = [NSArray arrayWithObjects: buFlex, buAdd, buFlex, nil];
	[self setToolbarItems:buArray animated:YES];
	//[buAdd release];
	//[buFlex release];
}

/*
// nibファイルでロードされたオブジェクトを初期化する
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef AzPAD
	// viewWillAppear:に入れると再描画時に通ってBarが乱れるため、ここにした。 loadViewに入れると配下から戻ったときダメ
	// SplitViewタテのとき [Menu] button を表示する
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (app.barMenu) {
		UIBarButtonItem* buFlexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		UIBarButtonItem* buTitle = [[[UIBarButtonItem alloc] initWithTitle: self.title  style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
		NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: app.barMenu, buFlexible, buTitle, buFlexible, nil];
		UIToolbar* toolBar = [[[UIToolbar alloc] init] autorelease];
		toolBar.barStyle = UIBarStyleDefault;
		[toolBar setItems:items animated:NO];
		[toolBar sizeToFit];
		self.navigationItem.titleView = toolBar;
		[items release];
	}
#endif
	
	[self.navigationController setToolbarHidden:NO animated:animated]; // ツールバー表示する
}

/* SplitViewは、透明なので通らない！
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
*/


#pragma mark - Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
#ifdef AzPAD
	return YES;
#else
	return (interfaceOrientation == UIInterfaceOrientationPortrait); // 正面のみ許可
#endif
}

//[Menu]Popoverが開いたときに呼び出される
- (void)splitViewController:(UISplitViewController*)svc 
		  popoverController:(UIPopoverController*)pc 
  willPresentViewController:(UIViewController *)aViewController
{
	//NSLog(@"aViewController=%@", aViewController);
	UINavigationController* nc = (UINavigationController*)aViewController;
	TopMenuTVC* tv = (TopMenuTVC*)nc.visibleViewController;
	if ([tv respondsToSelector:@selector(setPopover:)]) {
		[tv setPopover:pc];	//内側から閉じるため
	}
	return;
}

// 横 => 縦 ： 左ペインが隠れる時に呼び出される
- (void)splitViewController:(UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController 
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController:(UIPopoverController*)pc
{	//左ペインが消えたので、右ペインに[Menu]ボタンを表示する
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	app.barMenu = barButtonItem;	//下層のVCへも設置するため保持する
	//
	UINavigationController *nc = [svc.viewControllers objectAtIndex:1];
	UIViewController *rightVC = nc.visibleViewController;
	NSLog(@"rightVC.title=%@", rightVC.title);
	barButtonItem.title = @"    M e n u    ";		// @"    T o p    ";
	barButtonItem.enabled = YES;
#ifdef AzMAKE_SPLASHFACE
	barButtonItem.enabled = NO;
#endif
	UIBarButtonItem* buFlexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem* buTitle = [[[UIBarButtonItem alloc] initWithTitle: rightVC.title  style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: barButtonItem, buFlexible, buTitle, buFlexible, nil];
	UIToolbar* toolBar = [[[UIToolbar alloc] init] autorelease];
	toolBar.barStyle = UIBarStyleDefault;
	[toolBar setItems:items animated:NO];
	[toolBar sizeToFit];
	rightVC.navigationItem.titleView = toolBar;
	[items release];
	//
	//self.menuPopoverController = pc; //保持する
}

// 縦 => 横 ： 左ペインが現れる時に呼び出される
- (void)splitViewController:(UISplitViewController*)svc
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{	//左ペインが現れたので、右ペインの[Menu]ボタンを消す
	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	app.barMenu = nil;
	//
	UINavigationController *nc = [svc.viewControllers objectAtIndex:1];
	UIViewController *rightVC = nc.visibleViewController;
	NSLog(@"rightVC.title=%@", rightVC.title);
	barButtonItem.title = nil;
	barButtonItem.enabled = NO;
	UIBarButtonItem* buFlexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	UIBarButtonItem* buTitle = [[[UIBarButtonItem alloc] initWithTitle: rightVC.title  style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	NSMutableArray* items = [[NSMutableArray alloc] initWithObjects: buFlexible, buTitle, buFlexible, nil];
	UIToolbar* toolBar = [[[UIToolbar alloc] init] autorelease];
	toolBar.barStyle = UIBarStyleDefault;
	[toolBar setItems:items animated:NO];
	[toolBar sizeToFit];
	rightVC.navigationItem.titleView = toolBar;
	[items release];
	//
	//self.menuPopoverController = nil; //解放する
}


@end
