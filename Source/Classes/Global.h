//
//  Global.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
//#define AzDEBUG  プロジェクト設定にて"GCC_PREPROCESSOR_DEFINITIONS"定義した

//#define AzMAKE_SPLASHFACE  // 起動画面 Default.png を作るための作業オプション

/*
 #ifdef AzSTABLE
 // 広告なし
 #else
 #define GD_Ad_ENABLED
 #define MY_BANNER_UNIT_ID	@"a14d4c11a95320e";		//AdMobパブリッシャー ID  "クレメモ Free"　
 #endif
 */

#if defined(AzSTABLE) || defined(AzMAKE_SPLASHFACE)
	// 広告なし
#else // AzFREE
	#define FREE_AD
	#ifdef AzPAD
		//FREE_ADに統一// #define FREE_AD_PAD
		#define AdMobID_iPad		@"a14df22df88250c";		//AdMobパブリッシャー ID  "クレメモ Free for iPad"
	#else
		#define AdMobID_iPhone	@"a14d4c11a95320e";		//AdMobパブリッシャー ID  "クレメモ Free for iPhone"　
	#endif
#endif

#define OR  ||

#ifdef AzDEBUG	//--------------------------------------------- DEBUG
#define AzLOG(...) NSLog(__VA_ARGS__)
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }

#else	//----------------------------------------------------- RELEASE
		// その他のフラグ：-DNS_BLOCK_ASSERTIONS=1　（NSAssertが除去される）
#define AzLOG(...) 
#define NSLog(...) 
#define AzRETAIN_CHECK(...) 
#endif


#define GD_PRODUCTNAME	@"AzCredit"  // IMPORTANT PRODUCT NAME  和名「クレメモ」
													//↑↑変更禁止！！Keychainの'ServiceName'に使っているので読み出せなくなる。
#define GD_KEY_LOGINPASS  @"AzCreditLoginPass"  //←変更禁止！！Keychainの'Username'に使っているので読み出せなくなる。

/*----- GD_PRODUCTNAME を変更するときに必要となる作業の覚書 -------------------------------
 ＊ソース変更
	AppDelegete.m にて NSBundle名に GD_PRODUCTNAME が渡されている。以下適切に変更しなければ、ここでフリーズする

 *実体ファイル名変更と同時に、XCODEから各ファイルの情報を開いて、実体を再指定(リンク)する
	AzCredit					ルートフォルダ名
	AzCredit_Prefix.pch		プリコンパイルヘッダ
	AzCredit.xcmappingmodel	データマッピング
	AzCredit.xcdatamodeld		データモデル

 ＊XCODE＞プロジェクト＞アクティブターゲット"AzCredit"を編集
		＞一般＞名前を変更
		＞ビルド＞プリダクト名、GCC_PREFIX_HEADRER を変更
		＞プロパティ＞旧名があれば変更

 *iPhoneシニュレータ＞コンテンツと設定をリセット

 *XCODE＞キャッシュを空にする

 *XCODE＞ビルド＞すべてのターゲットをクリーニング

 *XCODE＞ビルドして進行
 -----------------------------------------------------------------------*/

#define AzMIN_YearMMDD		20000326
#define AzMAX_YearMMDD		21001231
#define AzMAX_AMOUNT			99999999	// Max99,999,999円
#define AzMAX_NAME_LENGTH		50		//[0.2c] .name 最大文字数
#define AzMAX_NOTE_LENGTH		200		//[0.2c] .note 最大文字数

#define GD_COREDATANAME		@"AzCredit.sqlite"	// CoreData Saved SQLlite File name
#define GD_GDOCS_EXT				@".AzCredit"			// Google Document Spredseet.拡張子
#define GD_CSVFILENAME				@"AzCredit.csv"		// Local Save file name
#define GD_CSVBACKFILENAME	@"AzCreditBack.csv"	// Local Save file name 直前バックアップ

#define GD_SECTION_TIMES	100000				// .tag = .section * GD_SECTION_TIMES + .row に使用
#define GD_E2SORTLIST_COUNT		3				// E2 Sort Listの有効行数

#define GD_KeyboardHeightPortrait			216.0f		// タテ向きのときのキーボード高さ
#define GD_KeyboardHeightLandscape	160.0f		// ヨコ向きのときのキーボード高さ
#define GD_PickerHeight							216.0f		// PICKERの高さ

// standardUserDefaults Setting Plist KEY
#define GD_DefPassword						@"DefPassword"
#define GD_DefUsername						@"DefUsername"

// Option SettingTVC Plist KEY     初期値定義は、<applicationDidFinishLaunching>内
//#define GD_OptBootTopView					@"OptBootTopView"		// 起動時トップ  [0.4]以降廃止(バックグランド復帰のとき無意味になるため）
//#define GD_OptAntirotation					@"OptAntirotation"		// 画面回転
//#define GD_OptEnableSchedule				@"OptEnableSchedule"	// 支払予定
//#define GD_OptEnableCategory				@"OptEnableCategory"	// 分類
#define GD_OptEnableInstallment				@"OptEnableInstallment"	// 分割払い
#define GD_OptNumAutoShow					@"OptNumAutoShow"		// ＜保留＞ テンキー自動表示
#define GD_OptFixedPriority					@"OptFixedPriority"		// ＜保留＞ 修正を優先
//#define GD_OptAmountCalc					@"OptAmountCalc"		// [0.3.1] 電卓使用
#define GD_OptRoundBankers					@"OptRoundBankers"		// [0.4] 偶数丸め
#define GD_OptTaxRate						@"OptTaxRate"			// [0.4] float 消費税率(%)


// Option Other Plist KEY
#define GD_OptPasswordSave					@"OptPasswordSave"
#define GD_OptUseDateTime					@"OptUseDateTime"
#define GD_OptE4SortMode					@"OptE4SortMode"
#define GD_OptE5SortMode					@"OptE5SortMode"


#ifdef AzPAD
#define GD_PAIDLIST_MAX			30		// E2,E7一覧で表示するPAID側の最大件数、Unpaid側は全件
#define GD_E3_SELECT_LIMIT		100		// 明細一覧で中央日付から前後抽出する件数(Limit)
#else
#define GD_PAIDLIST_MAX			20		// E2,E7一覧で表示するPAID側の最大件数、Unpaid側は全件
#define GD_E3_SELECT_LIMIT		50		// 明細一覧で中央日付から前後抽出する件数(Limit)
#endif

#ifdef AzPAD
#define GD_POPOVER_SIZE_INIT		CGSizeMake(480-1, 500-1)	//init初期化時に使用　＜＜＜変化ありにするため1廻り小さくする
#define GD_POPOVER_SIZE				CGSizeMake(480, 500)			//viewDidAppear時に使用
#endif



//----------------------------------------------- Global.m グローバル関数
UIColor *GcolorBlue(float percent) ;

NSString *GstringMonth( NSInteger PiMonth ) ;

NSString *GstringDay( NSInteger PlDay ) ;

NSString *GstringYearMMDD(NSInteger PlYearMMDD );

//NSInteger GiYear( NSInteger iYearMMDD );
//NSInteger GiMonth( NSInteger iYearMMDD );
NSInteger GiDay( NSInteger iYearMMDD );

NSInteger GiYearMMDD( NSDate *dt );
NSInteger GiYearMMDD_ModifyDay( NSInteger iYearMMDD, NSInteger iDD );

NSInteger GlAddYearMM(NSInteger lYearMM, 
					  NSInteger lMonth );

NSInteger GiAddYearMMDD(NSInteger iYearMMDD, 
						NSInteger iAddYear,
						NSInteger iAddMM, 
						NSInteger iAddDD );

UIImage *GimageFromString(NSString* str);

NSDate *GdateYearMMDD(NSInteger PiMinYearMMDD, 
					  NSInteger PiHour, 
					  NSInteger PiMinute, 
					  NSInteger PiSecond );

void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton );




////----------------------------------------------- Google Analytics
//#import "GANTracker.h"
//
//#define __GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) \
//[[GANTracker sharedTracker] startTrackerWithAccountID:ACCOUNT \
//dispatchPeriod:PERIOD delegate:DELEGATE];
//#ifdef DEBUG
//#define GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) { \
//__GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE); \
//[GANTracker sharedTracker].debug = YES; \
//[GANTracker sharedTracker].dryRun = YES; }
//#else
//#define GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE) __GA_INIT_TRACKER(ACCOUNT, PERIOD, DELEGATE);
//#endif
//
//#define GA_TRACK_PAGE(PAGE) { NSError *error; if (![[GANTracker sharedTracker] \
//trackPageview:[NSString stringWithFormat:@"/%@", PAGE] \
//withError:&error]) { NSLog(@"GA_TRACK_PAGE: error: %@",error.helpAnchor);  } }
//
//#define GA_TRACK_EVENT(EVENT,ACTION,LABEL,VALUE) { \
//NSError *error; if (![[GANTracker sharedTracker] trackEvent:EVENT action:ACTION label:LABEL value:VALUE withError:&error]) \
//{ NSLog(@"GA_TRACK_EVENT: error: %@",error.helpAnchor); }  }
//
//#define GA_TRACK_CLASS  { GA_TRACK_PAGE(NSStringFromClass([self class])) }
//#define GA_TRACK_METHOD { GA_TRACK_EVENT(NSStringFromClass([self class]),NSStringFromSelector(_cmd),@"",0); }
//
//#define GA_TRACK_LOG(LABEL)  { \
//NSString *_zLabel_ = [NSString stringWithFormat:@"(%d)%@",__LINE__,LABEL]; \
//NSLog(@"GA_TRACK_LOG: %@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),_zLabel_); \
//GA_TRACK_EVENT(NSStringFromClass([self class]),NSStringFromSelector(_cmd),_zLabel_,0); }
//
//#define GA_TRACK_ERROR(LABEL)  { \
//NSString *_zAction_ = [NSString stringWithFormat:@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd)]; \
//NSString *_zLabel_ = [NSString stringWithFormat:@"(%d)%@",__LINE__,LABEL]; \
//NSLog(@"GA_TRACK_ERROR: %@ %@",_zAction_,_zLabel_); \
//GA_TRACK_EVENT(@"ERROR",_zAction_,_zLabel_,0); }
//
//// 以下、非推奨
//#define GA_TRACK_METHOD_LABEL(LABEL,VALUE)		GA_TRACK_LOG(LABEL)
//#define GA_TRACK_EVENT_ERROR(LABEL,VALUE)			GA_TRACK_ERROR(LABEL)


//END
