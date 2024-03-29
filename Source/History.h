//
//  History.h
//  PayNote(AzCredit) クレメモ
//
//  Created by 松山正和 on 2017/05/05.
//  Copyright 2009 Masakazu Matsuyama / Engineer LLC. All rights reserved.
//

/* 履歴事項を記録する（リソースに組み込まれないようにヘッダコメントにしている）
 
 
 
 [1.2]-----------------------------------------2017/7/17----------------------
 ・iOS10,arm64対応
 ・プロダクツ統合、4BundleをUniversal対応して1つ（com.azukid.AzCreditS1）にする
 ・Xcode8.3.3 - iOS10.3.3
 ・CocoaPods導入
 ・商標登録「クレメモ」第9類、第42類
 ・PAD：ポップアップ廃止、GoogleやPCへの接続廃止
 ・PAD：SplitViewの常時2分割に対応
 ・iCloud Drive対応、プロダクツ移行させるため
 

 
 [1.1.x]---------------------------------------
 ・プロダクツライン
 　Apple ID  名前                      バンドルID
 　432458298 「クレメモ」               5C2UYK6F45.com.azukid.AzCreditS1
 　363741814 「クレメモ Free」　        JE9S39F69E.com.azukid.AzukiSoft.AzCredit
 　457542400 「クレメモ for iPad」 　   5C2UYK6F45.com.azukid.AzCreditS1Pad
 　446376779 「クレメモ Free for iPad」 5C2UYK6F45.com.azukid.AzCreditPadFree
 
 
 これより Git バージョン管理開始
 [0.4.20]-----------------------------------------2011/2/9----------------------RC4-Upload
	・Bug:E3一覧から戻って"しばらく"すると落ちる（実機でのみ発生）
 原因＞ E3一覧が破棄された後にAdMobのdelegate呼び出しが発生していた。
 対応＞ E3一覧のdealloc時に .delegate = nil;
 RoAdMobView.delegate = nil;
 [RoAdMobView release];
 RoAdMobView = nil;
 ・iAdも同様に dealloc: にて MbannerView.delegate = nil; & release した。
 ◆◆◆ 通信受信関係は同様の注意が必要と思われる。
 
 [0.4.19]-----------------------------------------2011/2/8----------------------RC3
	・Class MocFunctions
 static NSManagedObjectContext *scMoc = nil;
	・Bug:E3detail,E4shopなどで保存前に終了＞バックグランド＞復帰したとき、画面は復帰するがEntityデータは失われている
 原因＞ 終了処理でMOC:rollbackしているため。
 commitすると、復帰後のCancelができない。
 対応＞「applicationWillTerminate > hasChanges > rollback」を廃止。
 ・終了＞バックグランド＞復帰した場合、MOCは維持されているため。
 ・終了＞破棄された場合、MOCはcommit以降は破棄されるのでrollbackと同じ。
 これにて、applicationWillTerminate時の処理は、全く無くなった。
	・新しいスクリーンショット作成
 Retina対応も作成
	・Bug:Cardメモにコンマ[,]を使って、バックアップ＞リストアすると[,]以降が支払口座(Account)として追加されてしまう。
 Gドキュメントを見るとバックアップは正常。リストアに問題あり
 原因＞ CSV読み込み時、"文字列区間" 内にあるコンマ[,]が区切り記号[,]と同様に区切られていた。
 対応＞ 区切り記号[,]で区切られた配列(MaCsv)を調べて、["]で始まり["]で終わるまでを[,]を加えて結合する処理を入れた。
 
 [0.4.18]-----------------------------------------2011/2/6----------------------
	・Retina @2x 対応
 //UIGraphicsBeginImageContext(imageView1.image.size);
 UIGraphicsBeginImageContextWithOptions(imageView1.image.size, NO, 0.0); //[0.4.18]Retina対応
	・＋Addアイコン Retina対応
	・Default@2x.png、Icon@2x.png Retina対応
	・E6 チェック時のレス向上のため、1セルだけ再描画
 NSArray *aIndex = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:iRow inSection:iSec]];
 [self.tableView reloadRowsAtIndexPaths:aIndex withRowAnimation:NO];
	・Bug:E6-->E3Detail-->E6でCheck すると落ちる
 原因＞編集(行移動)による支払日変更のため翌月の空E2を追加表示しているが、
 E3detailから戻るとき空E2とE7が削除されるようになっていた。
 また、先日の改造によりE3detail-->E6にCancelで戻ったとき、レス向上のため再描画しないようになった。
 これにより、削除されたE2が選択されて落ちた。
 対応＞E2,E7を随時削除しないようにした。他の箇所でも同様。
 TopMenu:viewDidAppear だけで [EntityRelation e7e2clean] を呼び出して
 空のE2,E7をクリーンアップするようにした。
 
 [0.4.17]-----------------------------------------2011/2/5----------------------
	・Retina @2x 対応
	・アイコンpng関係整理
 Icon16.svg  主にToolBar用の 16x16 アイコン
 Icon32.svg  主にCell用の 32x32 アイコン
 Icon32-from512.svg 512x512ソースから32x32生成
 Icon.svg アプリアイコン
 
 [0.4.16]-----------------------------------------2011/2/4----------------------
	・AdMob対応：E3,E6に表示。　TopMenuにはiAd
 
 [0.4.15]-----------------------------------------2011/2/3----------------------
	・Bug:E8-->E3detail SAVEすると落ちる。 E1-->E3detail SAVEは正常。
 原因＞E3save時、E6remake発生、E6親側のテーブルソース(RaE2invoices)配下のE6が参照できなくなるため
 対応＞e3makeE6 にて、E6再生成時にE2を削除しないようにした。
	・英語Splash画面「Crememo」の Default.png を作成、交換
	・申請候補
 
 [0.4.14]-----------------------------------------2011/2/2----------------------
	・Bug:E1,E8一覧(E2)からPAID切り替えしたときRepeatされない
 支払予定(E7)一覧からのPAID切り替えと別処理になっていた。
	・Bug:E4,E5 検索すると落ちる
 predicateWithFormatで %K が @K に間違っていた。固定名なので%K使用を止めた。
 
 [0.4.13]-----------------------------------------2011/2/1----------------------
	・E3一覧を中央日付から前後最大50件抽出する方式にした。
 
 [0.4.12]-----------------------------------------2011/2/1----------------------
	・Googleアップロード時のインジケータ表示を早くしようとしたがダメだった。保留
	・Fix:E8-->E2 最後の20件でない
	・Fix:LoginPassViewを破棄しないようにしたら、E4一覧選択で落ちるようになった。
 原因＞[NSUserDefaults standardUserDefaults]への書き込みで落ちる
 多分、同時発生している可能性がある。
 対応＞E4,E5ともソート指定を常に初期0(最近)にした。
	・バックグランド対応により viewComeback 廃止した。起動が軽くなった？
 
 [0.4.11]-----------------------------------------2011/1/30----------------------
	・クリーニング、Build and Anlyze により静的リーク検査 PASS
 メッソッド名に copy が含まれていて、内部に alloc,new が無ければAnlyze警告出ることを知った。
	・電卓：計算式の先頭が[-]や[+]ならば符号として処理
	・E3recordDetailTVC 支払明細(E6)をクリックしたとき、「支払日の変更方法」メッセージ表示する
 ここで支払日を変更可能にしようとしたが、同時にカードを変更された場合など複雑になるので取りやめた。
 
 
 [0.4.10]-----------------------------------------2011/1/29----------------------
	・電卓ボタン：押下時のデザイン変更
	・PAIDスタンプを青色にした
	・Unpaidスタンプを赤色にした
	・E2,E7一覧にてPAID側を最大20件までに制限した
 
 [0.4.9]-----------------------------------------2011/1/28----------------------
	・電卓：逆ポーランド記法変換および計算処理の改良　＞＞＞ AzPack, AzCalc へ活用する
 NSMutableArrayにStackメソッド(push,pop)をカテゴリ実装した
 小数有効桁数：	最終表示＝通貨桁数（￥=0桁、＄=2桁）
 計算結果表示＝通貨桁数＋2桁
 計算内部処理＝通貨桁数＋12桁＆常に偶数丸め
 
 [0.4.8]-----------------------------------------2011/1/27----------------------
	・電卓：計算処理改造（未完）
	・設定：偶数丸め を新設
 金額の丸め処理に偶数丸めを選択できる。デフォルトは四捨五入。
	・設定：消費税率(%)を新設
 初期値：Ja=5  En=0
 
 [0.4.7]-----------------------------------------2011/1/24----------------------
	・電卓キー配列変更
 UIScrollViewによるヨコページ導入
 
 [0.4.6]-----------------------------------------2011/1/23----------------------
	・金額関係をDecimal(十進)型に変えてセント対応した
 金額関係を全てNSDecimalNumberに変更、MOCでは「十進」
 電卓の途中計算は＋2桁とし、結果は常に通貨に合わせて丸める
 丸めは「Bankers：偶数丸め」を採用した
	・バックアップファイル名に "HH:mm" 時:分 を付加した
	・ログインパスワードを忘れた場合の手順確認
 アプリ削除によりパスワードが削除されることを確認
 再インストールすることにより初期状態に戻ることを確認
	・E3recordDetailTVC:前後コピー機能
 繰り越しなどによる先日付に対応するため、原点を「現在」にする
 現在以前の20件まで参照できるようにした
 
 [0.4.5]-----------------------------------------2011/1/22----------------------
	・gdata-objectivec-client-1.11.0 に対応
	　　・静的ライブラリ GDataTouchStaticLib をビルドする手順
 Source/GData.xcodeproj ダブルクリック Xcode起動
 　（GDataOAuthTouchStaticLibrary.xcodeproj は、OAuthだけを使いたい時に使用）
 ターゲット/GDataTouchStaticLib ダブルクリック ビルドオプション
 iOS Deployment Target 最下位バージョンにする　iOS 3.0
 アーキテクチャ　Standard にする（旧機種対応のため）
 ベースSDK　最新バージョンにする
 その他のCフラグ(OTHER_CFLAGS) に追加
 -DDEBUG=1
 -DGDATA_IPHONE=1		　　　<<<ここまでだけなら全サービスをビルド
 -DGDATA_REQUIRE_SERVICE_INCLUDES=1　　<<<以下のサービスだけビルドすることを指示
 -DGDATA_INCLUDE_DOCS_SERVICE=1
 -DGDATA_INCLUDE_SPREADSHEET_SERVICE=1
 -D<<<他にも必要なサービスがあれば追加>>>
 ビルドする
 Simulator/Debug
 Device/Debug
 Device/Release
	　　・AzCreditプロジェクトに加える
 AzCredit-0.4.xcodeproj ダブルクリック Xcode起動
 プロジェクトープロジェクトに追加…　GData.xcodeproj を追加する
 libGDataTouchStaticLib.a だけが黒文字になっている　ターゲットをチェックする
 ターゲット/AzCredit ダブルクリック
 「一般」ー「直接依存関係」に GDataTouchStaticLib を追加する
 「ビルド」ー「他のリンカフラグ」＋「-lxm2」
 ー「ヘッダ検索パス」＋「/usr/include/libxml2」
 ー「ユーザヘッダ検索パス」＋へパス追加する変わりに下記フォルダを追加することも可
 /build/Release-iphoneos/Headers をXcodeグループ内へドラッグドロップする
 
	・英語名称を「Crememo」「Credit Memorandum」にした。
 Credit memo、クレジットメモ には、ファイナンス用語として割戻金の意味があるから避ける。
 日本語は「クレメモ」にままだが、フルネームを「クレジット手記」にする。
 
 [0.4.4]-----------------------------------------2011/1/21----------------------
	・E3recordTVC:明細の無いセクションを表示しないようにした
 E4shopなどから呼び出されたとき、見やすくなった
	
	・NSDateは、常にUTC(+0000)であることを改めて確認した
 つまりCoreDataなど内部は全てUTCで処理している
 表示の際にNSDateFormatterなどを使ってタイムゾーン変換している
 
 [0.4.3]-----------------------------------------
	・E3recordTVC:レス向上
	　　・画面中央明細を含む月の前後数ヶ月範囲を抽出描画する
	　　・範囲両端行に「さらに前へ」「さらに次へ」を表示
	　　　それぞれ、端の明細を含む月の前後数ヶ月範囲を抽出描画する
 
	・E3recordTVC:初期中央に「本日」を表示
	　　・繰り越しなどによる支払予定が見えるように
 
	・E3recordTVC:E3recordDetailTVCから戻ったときの表示を最適化
	　　・キャンセルで戻ったときは再描画しないようにした。
	　　・保存で戻ったとき、利用日が中央になるように再描画する
 
 [0.4.2]-----------------------------------------
	・当日締⇒当日払に加えて n日後払 に対応
 
 [0.4.1]-----------------------------------------
	・ログインパスワード
 起動時およびバックグランドから復帰したときパスワードが求められる
 パスワードを登録しなければ従来通りフリー
 
	・繰り返し　なし、1ヶ月後、2ヶ月後、1年後
 PAIDになるタイミングでコピーして利用日を指定された日付にする
 
 組み込みモジュール
	・gdata-objectivec-client-1.10
 
 */
