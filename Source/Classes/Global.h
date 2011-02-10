//
//  Global.h
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

//#define AzMAKE_SPLASHFACE  // 起動画面 Default.png を作るための作業オプション
//#define AzDEBUG  プロジェクト設定にて"GCC_PREPROCESSOR_DEFINITIONS"定義した

#define OR  ||

#ifdef AzDEBUG 
#define AzLOG(...) NSLog(__VA_ARGS__)
#else
#define AzLOG(...) 
#endif

#ifdef AzDEBUG
#define AzRETAIN_CHECK(zName,pObj,iAns)  { if ([pObj retainCount] > iAns) NSLog(@"AzRETAIN_CHECK> %@ %d > %d", zName, [pObj retainCount], iAns); }
#else
#define AzRETAIN_CHECK(...) 
#endif


#define GD_PRODUCTNAME	@"AzCredit"  // IMPORTANT PRODUCT NAME  和名「クレメモ」
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
#define AzMAX_AMOUNT		99999999	// Max99,999,999円
#define AzMAX_NAME_LENGTH		50		//[0.2c] .name 最大文字数
#define AzMAX_NOTE_LENGTH		200		//[0.2c] .note 最大文字数

#define GD_COREDATANAME		@"AzCredit.sqlite"	// CoreData Saved SQLlite File name
#define GD_GDOCS_EXT		@".AzCredit"		// Google Document Spredseet.拡張子
#define GD_CSVFILENAME		@"AzCredit.csv"		// Local Save file name
#define GD_CSVBACKFILENAME	@"AzCreditBack.csv"	// Local Save file name 直前バックアップ

#define GD_SECTION_TIMES	100000				// .tag = .section * GD_SECTION_TIMES + .row に使用
#define GD_E2SORTLIST_COUNT		3				// E2 Sort Listの有効行数

#define GD_KeyboardHeightPortrait	216.0f	// タテ向きのときのキーボード高さ
#define GD_KeyboardHeightLandscape	160.0f	// ヨコ向きのときのキーボード高さ
#define GD_PickerHeight				216.0f	// PICKERの高さ

// standardUserDefaults Setting Plist KEY
#define GD_DefPassword						@"DefPassword"
#define GD_DefUsername						@"DefUsername"

// Option SettingTVC Plist KEY     初期値定義は、<applicationDidFinishLaunching>内
#define GD_OptBootTopView					@"OptBootTopView"		// 起動時トップ
#define GD_OptAntirotation					@"OptAntirotation"		// 画面回転
//#define GD_OptEnableSchedule				@"OptEnableSchedule"	// 支払予定
//#define GD_OptEnableCategory				@"OptEnableCategory"	// 分類
#define GD_OptEnableInstallment				@"OptEnableInstallment"	// 分割払い
#define GD_OptNumAutoShow					@"OptNumAutoShow"		// ＜保留＞ テンキー自動表示
#define GD_OptFixedPriority					@"OptFixedPriority"		// ＜保留＞ 修正を優先


// Option Other Plist KEY
#define GD_OptPasswordSave					@"OptPasswordSave"
#define GD_OptUseDateTime					@"OptUseDateTime"
#define GD_OptE4SortMode					@"OptE4SortMode"
#define GD_OptE5SortMode					@"OptE5SortMode"


//----------------------------------------------- Global.m グローバル関数
UIColor *GcolorBlue(float percent) ;

NSString *GstringMonth( NSInteger PiMonth ) ;

NSString *GstringDay( NSInteger PlDay ) ;

NSString *GstringYearMMDD(NSInteger PlYearMMDD );

NSInteger GiYearMMDD( NSDate *dt );

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


