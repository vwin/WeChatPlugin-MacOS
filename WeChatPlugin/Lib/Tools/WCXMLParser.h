//
//  WCXMLParser.h
//  WeChatPlugin
//
//  Created by YJHou on 2017/8/16.
//  Copyright © 2017年 houmanager@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XMLReaderOptions) {
    XMLReaderOptionsProcessNamespaces           = 1 << 0, // Specifies whether the receiver reports the namespace and the qualified name of an element.
    XMLReaderOptionsReportNamespacePrefixes     = 1 << 1, // Specifies whether the receiver reports the scope of namespace declarations.
    XMLReaderOptionsResolveExternalEntities     = 1 << 2, // Specifies whether the receiver reports declarations of external entities.
};

@interface WCXMLParser : NSObject <NSXMLParserDelegate>

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data options:(XMLReaderOptions)options error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string options:(XMLReaderOptions)options error:(NSError **)errorPointer;

@end
