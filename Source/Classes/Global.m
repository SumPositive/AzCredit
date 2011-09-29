//
//  Global.m	クラスメソッド（グローバル関数）
//  AzCredit
//
//  Created by 松山 和正 on 09/12/03.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Global.h"

UIColor *GcolorBlue(float percent) 
{
	float red = percent * 255.0f;
	float green = (red + 20.0f) / 255.0f;
	float blue = (red + 45.0f) / 255.0f;
	if (green > 1.0) green = 1.0f;
	if (blue > 1.0f) blue = 1.0f;
	
	return [UIColor colorWithRed:percent green:green blue:blue alpha:1.0f];
}

/*
static NSString *GstringYearMM( NSInteger PlYearMM ) 
{
	// "%ld" のために long を使っている。
	long lYear = PlYearMM / 100;
	long lMM = PlYearMM - (lYear * 100);
	return [NSString stringWithFormat:NSLocalizedString(@"FormatYearMM",nil), lYear, lMM];
}
*/

NSString *GstringMonth( NSInteger PiMonth ) 
{
	switch (PiMonth) {
		case  1: return NSLocalizedString(@"January",nil);	break;
		case  2: return NSLocalizedString(@"February",nil); break;
		case  3: return NSLocalizedString(@"March",nil);	break;
		case  4: return NSLocalizedString(@"April",nil);	break;
		case  5: return NSLocalizedString(@"May",nil);		break;
		case  6: return NSLocalizedString(@"June",nil);		break;
		case  7: return NSLocalizedString(@"July",nil);		break;
		case  8: return NSLocalizedString(@"August",nil);	break;
		case  9: return NSLocalizedString(@"September",nil); break;
		case 10: return NSLocalizedString(@"October",nil);	break;
		case 11: return NSLocalizedString(@"November",nil); break;
		case 12: return NSLocalizedString(@"December",nil); break;
	}
	return @"";
}

NSString *GstringDay( NSInteger PlDay ) 
{
	switch (PlDay) {
		case 1:
			return NSLocalizedString(@"1st",nil);
			break;
		case 2:
			return NSLocalizedString(@"2nd",nil);
			break;
		case 3:
			return NSLocalizedString(@"3rd",nil);
			break;
		default:
			if (28 < PlDay) {
				return NSLocalizedString(@"EndDay",nil); // 末日
			}
			else if (3 < PlDay) {
				return [NSString stringWithFormat:@"%ld%@", PlDay, NSLocalizedString(@"th",nil)];
			}
			break;
	}
	return nil;
}

NSString *GstringYearMMDD( NSInteger PlYearMMDD ) 
{
	// "%ld" のために long を使っている。
	long lYear = PlYearMMDD / 10000;
	long lMM = (PlYearMMDD - (lYear * 10000)) / 100;
	long lDD = PlYearMMDD - (lYear * 10000) - (lMM * 100);
	return [NSString stringWithFormat:NSLocalizedString(@"FormatYearMMDD",nil), lYear, lMM, lDD];
}

NSInteger GiDay( NSInteger iYearMMDD )
{
	return iYearMMDD - ((iYearMMDD / 100) * 100);  // >=29:月末
}

// NSDate --> lYearMMDD
NSInteger GiYearMMDD( NSDate *dt )
{
	//NSCalendar *cal = [NSCalendar currentCalendar];
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [calendar components:unitFlags fromDate:dt];
	NSInteger iYearMMDD = comp.year * 10000 + comp.month * 100 + comp.day;
	//[comp release]; autorelease
	[calendar release];
	return iYearMMDD;
}

// lYearMM を lMonth ヶ月 (+)進める (-)戻す
NSInteger GlAddYearMM( NSInteger lYearMM, NSInteger lMonth )
{
	// NSInteger は 32bitCPUならば32bitLONG型、64bitCPUならば64bitLONGLONG型になり最速演算される
	NSInteger lYear = lYearMM / 100;
	NSInteger lMM = lYearMM - (lYear * 100);
	lMM += lMonth;
	lYear += (lMM / 12);
	lMM = lMM - ((lMM / 12) * 12);
	return lYear * 100 + lMM;
}

NSInteger GiAddYearMMDD(NSInteger iYearMMDD, 
						NSInteger iAddYear,
						NSInteger iAddMM, 
						NSInteger iAddDD )	// >= 28 ならば移動先の月の末日になる 
{
	//NSCalendar *cal = [NSCalendar currentCalendar];
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	comp.year = iYearMMDD / 10000;
	comp.month = (iYearMMDD - comp.year * 10000) / 100;
	NSInteger iDay = iYearMMDD - (comp.year * 10000) - (comp.month * 100);
	comp.day = 1; // 1日にする
	NSDate *date1st = [calendar dateFromComponents:comp]; // 年月1日
	
	if (28 <= iDay) {  //  月末指定は29だが、2/28 の翌月を 3/31 とするため
		// 移動先の年月の「翌月の前日」にする
		comp.year = iAddYear;
		comp.month = iAddMM + 1;	// 移動先のさらに翌月
		comp.day = (-1);					// 1日の前日 ⇒ 末日になる
	} 
	else {
		comp.year = iAddYear;
		comp.month = iAddMM;
		comp.day = (iDay - 1) + iAddDD;
	}
	NSDate *dateNew = [calendar dateByAddingComponents:comp toDate:date1st options:0];
	[comp release]; // alloc生成しているので必要
	
	comp = [calendar components:unitFlags fromDate:dateNew];
	NSInteger iRet = comp.year * 10000 + comp.month * 100 + comp.day;
	//[comp release];　こちらはautorelease
	[calendar release];
	return iRet;
}

NSInteger GiYearMMDD_ModifyDay( NSInteger iYearMMDD, NSInteger iDay )		// iDay>=29:月末
{
	//NSCalendar *cal = [NSCalendar currentCalendar];
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	comp.year = iYearMMDD / 10000;
	comp.month = (iYearMMDD - comp.year * 10000) / 100;
	//NSInteger iDay = iYearMMDD - (comp.year * 10000) - (comp.month * 100);
	comp.day = 1; // 1日にする
	NSDate *date1st = [calendar dateFromComponents:comp]; // 年月1日
	
	if (29 <= iDay) {  //  月末
		// 移動先の年月の「翌月の前日」にする
		comp.year = 0;
		comp.month = 1;	// 翌月
		comp.day = (-1);	// 1日の前日 ⇒ 末日になる
	} 
	else {
		comp.year = 0;
		comp.month = 0;
		comp.day = (iDay - 1);  // 加算分を指定する
	}
	NSDate *dateNew = [calendar dateByAddingComponents:comp toDate:date1st options:0];
	[comp release]; // alloc生成しているので必要
	
	comp = [calendar components:unitFlags fromDate:dateNew];
	NSInteger iRet = comp.year * 10000 + comp.month * 100 + comp.day;
	//[comp release];　こちらはautorelease
	[calendar release];
	return iRet;
}

// 文字列から画像を生成する
UIImage *GimageFromString(NSString* str)
{
    UIFont* font = [UIFont systemFontOfSize:24]; //12.0; [0.4.17]Retina対応
    CGSize size = [str sizeWithFont:font];
    int width = 64; //32; [0.4.17]Retina対応
    int height = 64; //32;
    int pitch = width * 4;
	
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 第一引数を NULL にすると、適切なサイズの内部イメージを自動で作ってくれる
	CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, pitch, 
												 colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
	CGAffineTransform transform = CGAffineTransformMake(1.0,0.0,0.0, -1.0,0.0,0.0); // 上下転置行列
	CGContextConcatCTM(context, transform);
	
	// 描画開始
    UIGraphicsPushContext(context);
    
	CGContextSetRGBFillColor(context, 255, 0, 0, 1.0f);
	//[str drawAtPoint:CGPointMake(16.0f - (size.width / 2.0f), -23.5f) withFont:font];
	[str drawAtPoint:CGPointMake(32.0f - (size.width / 2.0f), -47.0f) withFont:font]; //[0.4.17]Retina対応
	
	// 描画終了
	UIGraphicsPopContext();
	
    // イメージを取り出す
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
	
    // UIImage を生成
    UIImage* uiImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return uiImage;
}

NSDate *GdateYearMMDD( NSInteger PiYearMMDD, int PiHour, int PiMinute, int PiSecond )
{
	NSInteger iYear = PiYearMMDD / 10000;
	NSInteger iDD = PiYearMMDD - (iYear * 10000);
	NSInteger iMM = iDD / 100;
	iDD -= (iMM * 100);
	
	//NSString *dateStr = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", 
	NSString *dateStr = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", 
							(int)iYear,(int)iMM,(int)iDD, PiHour,PiMinute,PiSecond];
	// strをNSDate型に変換
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];  
	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];  
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  
	//[1.1.2]システム設定で「和暦」にされたとき年表示がおかしくなるため、西暦（グレゴリア）に固定
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[dateFormatter setCalendar:calendar];
	[calendar release];
	NSDate *datetime = [dateFormatter dateFromString:dateStr];  //autorelease
	[dateFormatter release];  	
	[dateStr release];
	return datetime; // NSDateは、常にUTC(+0000)協定世界時間である。
}

void alertBox( NSString *zTitle, NSString *zMsg, NSString *zButton )
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:zTitle
													message:zMsg
												   delegate:nil
										  cancelButtonTitle:nil
										  otherButtonTitles:zButton, nil];
	[alert show];
	[alert release];
}
