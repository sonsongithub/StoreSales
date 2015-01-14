//
//  binaryIO.m
//
//  Created by sonson on 09/07/19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "binaryIO.h"

int loadNSString(FILE *fp, NSString **string) {
	int r1, r2;
	int byteLength = 0;
	char* p = NULL;
	r1 = (fread(&byteLength, sizeof(byteLength), 1, fp) > 0);
	p = (char*)malloc(sizeof(char) * (byteLength + 1));
	r2 = (fread(p, sizeof(char), byteLength, fp) > 0);
	p[byteLength] = '\0';
	*string = [[NSString alloc] initWithBytes:p length:byteLength encoding:NSUTF8StringEncoding];
	free(p);
	return (r1 & r2);
}

int loadNSDate(FILE *fp, NSDate **date) {
	double temp = 0;
	int r = (fread(&temp, sizeof(double), 1, fp) > 0);
	*date = [[NSDate dateWithTimeIntervalSinceReferenceDate:temp] retain];
	return r;
}

int loadInt(FILE *fp, int *value) {
	return (fread(value, sizeof(int), 1, fp) > 0);
}

int loadFloat( FILE *fp, float *value ) {
	return (fread(value, sizeof(float), 1, fp) > 0);
}

int loadDouble( FILE *fp, double *value ) {
	return (fread(value, sizeof(double), 1, fp) > 0);
}

int loadCGRect( FILE *fp, CGRect *value ) {
	return (fread(value, sizeof(CGRect), 1, fp) > 0);
}

int writeNSString( FILE *fp, NSString *string ) {
	int r1, r2;
	char *p = (char*)[string cStringUsingEncoding:NSUTF8StringEncoding];
	int byteLength = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	r1 = (fwrite(&byteLength, sizeof(byteLength), 1, fp) > 0);
	r2 = (fwrite(p, sizeof(char), byteLength, fp) > 0);
	return (r1 & r2);
}

int writeNSDate(FILE *fp, NSDate *date) {
	double temp = [date timeIntervalSinceReferenceDate];
	return (fwrite(&temp, sizeof(double), 1, fp) > 0);
}

int writeInt( FILE *fp, int *input ) {
	return (fwrite(input, sizeof(int), 1, fp) > 0);
}

int writeFloat( FILE *fp, float *input ) {
	return (fwrite(input, sizeof(float), 1, fp) > 0);
}

int writeDouble( FILE *fp, double *input ) {
	return (fwrite(input, sizeof(double), 1, fp) > 0);
}

int writeCGRect( FILE *fp, CGRect *value ) {
	return (fwrite(value, sizeof(CGRect), 1, fp) > 0);
}