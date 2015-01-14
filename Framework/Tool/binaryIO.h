//
//  binaryIO.h
//
//  Created by sonson on 09/07/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

int loadNSString(FILE *fp, NSString **string);
int loadNSDate(FILE *fp, NSDate **date);
int loadInt( FILE *fp, int *value );
int loadCGRect( FILE *fp, CGRect *value );
int loadFloat(FILE *fp, float *input);
int loadDouble(FILE *fp, double *value);

int writeNSString( FILE *fp, NSString *string );
int writeNSDate(FILE *fp, NSDate *date);
int writeInt( FILE *fp, int *input );
int writeCGRect( FILE *fp, CGRect *value );
int writeFloat(FILE *fp, float *input);
int writeDouble(FILE *fp, double *input);