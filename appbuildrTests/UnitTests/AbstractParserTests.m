/*
 * AbstractParserTests.m
 * appbuildr
 *
 * Created on 12/12/11.
 * 
 * Copyright (c) 2011 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * See Also: http://gabriel.github.com/gh-unit/
 */

#import "AbstractParserTests.h"
#import <OCMock/OCMock.h>
#import "AbstractParser.h"
#import "Link.h"

@interface AbstractParser(Private)
    -(NSString *)hrefForLinkElement:(CXMLElement *)propertyElement;
@end

@implementation AbstractParserTests

//CXMLNode
-(void)setUp
{
    AbstractParser* parser = [[[AbstractParser alloc]init] autorelease];
    niceMockParser = [[OCMockObject partialMockForObject:parser] retain];    
}

-(void)tearDown
{
    [niceMockParser release];
}

-(void)testGenerateGuidWithNillNodeTitle
{
    AbstractParser* parser = [[[AbstractParser alloc]init] autorelease];
    id mockParser = [OCMockObject partialMockForObject:parser];
    
    [[[mockParser expect]andReturn:OCMOCK_ANY]firstLinkHrefForItemNode:OCMOCK_ANY];
    NSString* link = @"test_link";
    [[[mockParser expect]andReturn:link]hrefForLinkElement:OCMOCK_ANY]; 
    [[[mockParser expect]andReturn: nil]titleForItemNode:OCMOCK_ANY];
    
    CXMLNode* node = [[[CXMLNode alloc] init] autorelease];
    
    GHAssertNotNil([mockParser generateGuidFromNodeInfo: node], nil);
    
    [mockParser verify];
}

-(void)testGenerateGuidWithNillNodeTitleAndNilHref
{
    AbstractParser* parser = [[[AbstractParser alloc]init] autorelease];
    id mockParser = [OCMockObject partialMockForObject:parser];
    
    [[[mockParser expect]andReturn:OCMOCK_ANY]firstLinkHrefForItemNode:OCMOCK_ANY];
    [[[mockParser expect]andReturn:nil]hrefForLinkElement:OCMOCK_ANY]; 
    [[[mockParser expect]andReturn: nil]titleForItemNode:OCMOCK_ANY];
    
    CXMLNode* node = [[[CXMLNode alloc] init] autorelease];
    
    GHAssertNil([mockParser generateGuidFromNodeInfo: node], nil);
    
    [mockParser verify];
}

-(void)testGenerateGuidWithNodeTitleAndNilHref
{
    AbstractParser* parser = [[[AbstractParser alloc]init] autorelease];
    id mockParser = [OCMockObject partialMockForObject:parser];
    
    [[[mockParser expect]andReturn:OCMOCK_ANY]firstLinkHrefForItemNode:OCMOCK_ANY];
    [[[mockParser expect]andReturn:nil]hrefForLinkElement:OCMOCK_ANY]; 
    [[[mockParser expect]andReturn:OCMOCK_ANY]titleForItemNode:OCMOCK_ANY];
    
    CXMLNode* node = [[[CXMLNode alloc] init] autorelease];
    
    GHAssertNotNil([mockParser generateGuidFromNodeInfo: node], nil);
    
    [mockParser verify];
}

#pragma mark Test case for link storage
-(id) mockNodeWithStringValue:(NSString*) value
{
     id node = [OCMockObject mockForClass:[CXMLNode class]];
    [[[node stub]andReturn:value]stringValue];
    return node;
}

-(id) mockElementWithType:(NSString*) type title:(NSString*)title rel:(NSString*) rel
{
    id mockPropertyElement = [OCMockObject mockForClass:[CXMLElement class]];
    [[[mockPropertyElement stub]andReturn:[self mockNodeWithStringValue:type]]attributeForName:@"type"];
    [[[mockPropertyElement stub]andReturn:[self mockNodeWithStringValue:title]]attributeForName:@"title"];
    [[[mockPropertyElement stub]andReturn:[self mockNodeWithStringValue:rel]]attributeForName:@"rel"];
    return mockPropertyElement;
}

-(id) mockLinkWithType:(NSString*) type title:(NSString*)title rel:(NSString*) rel url:(NSString*)url
{
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    [[mockLink expect] setHref:url];
    [[mockLink expect] setType:type];
    [[mockLink expect] setTitle:title];
    [[mockLink expect] setRel:rel];
    
    return mockLink;
}

-(void)testCreateLinkWithFullInformation
{   
    //Prepare test case
    NSString* linkExpectedtUrl = @"test_url";
    NSString* linkExpectedTitle = @"hello";
    NSString* linkExpectedType = @"html/text";
    NSString* linkExpectedRel = @"alternate";
    
    id mockPropertyElement = [self mockElementWithType:linkExpectedType title:linkExpectedTitle rel:linkExpectedRel];
    [[[niceMockParser stub]andReturn:linkExpectedtUrl]hrefForLinkElement:mockPropertyElement];
    
    id mockLink = [self mockLinkWithType:linkExpectedType title:linkExpectedTitle rel:linkExpectedRel url:linkExpectedtUrl];
    [[[niceMockParser stub]andReturn:mockLink]createObjectOfClass:[EntryLink class]];
    
    //Call test method
    Link* link = [niceMockParser createLinkFromXML:mockPropertyElement type:[EntryLink class]];
    
    //Check results
    GHAssertEquals(mockLink, link, @"");
    
    [mockLink verify];
}

-(void)testCreateLinkWithPartialInformation
{
    //Prepare test case
    NSString* linkExpectedtUrl = @"test_url";
    
    id mockPropertyElement = [self mockElementWithType:nil title:nil rel:nil];
    [[[niceMockParser stub]andReturn:linkExpectedtUrl]hrefForLinkElement:mockPropertyElement];
    
    id mockLink = [self mockLinkWithType:nil title:nil rel:nil url:linkExpectedtUrl];
    [[[niceMockParser stub]andReturn:mockLink]createObjectOfClass:[EntryLink class]];
    
    //Call test method
    Link* link = [niceMockParser createLinkFromXML:mockPropertyElement type:[EntryLink class]];
    
    //Check results
    GHAssertEquals(mockLink, link, @"");
    
    [mockLink verify];
}

-(void)testAddLinkInEmptyArray
{
    //Prepare test case
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    [[[mockLink stub]andReturn:@"alternate"]rel];
    [[[niceMockParser stub]andReturn:mockLink]createLinkFromXML:OCMOCK_ANY type:[EntryLink class]];
    
    //Call test method
    NSMutableArray* links = [[[NSMutableArray alloc] init] autorelease];
    [niceMockParser storeLinks:[OCMockObject mockForClass:[CXMLElement class]] item:links type:[EntryLink class]];
    
    //Check results
    GHAssertTrue([links count] == 1, @"");
}

-(void)testTryAddNilLinkInEmptyArray
{
    //Prepare test case
    [[[niceMockParser stub]andReturn:nil]createLinkFromXML:OCMOCK_ANY type:[EntryLink class]];
    
    //Call test method
    NSMutableArray* links = [[[NSMutableArray alloc] init] autorelease];
    [niceMockParser storeLinks:[OCMockObject mockForClass:[CXMLElement class]] item:links type:[EntryLink class]];
    
    //Check results
    GHAssertTrue([links count] == 0, @"");
}

-(void)testAddAlternateLinkToNonEmptyArray
{
    //Prepare test case
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    [[[mockLink stub]andReturn:@"alternate"]rel];
    [[[niceMockParser stub]andReturn:mockLink]createLinkFromXML:OCMOCK_ANY type:[EntryLink class]];
    
    //Call test method
    NSMutableArray* links = [NSMutableArray arrayWithObject:[OCMockObject mockForProtocol:@protocol(Link)]];
    [niceMockParser storeLinks:[OCMockObject mockForClass:[CXMLElement class]] item:links type:[EntryLink class]];
    
    //Check results
    GHAssertTrue([links count] == 2, @"");
    GHAssertEquals(mockLink, [links objectAtIndex:0], @"");
}

-(void)testAddLinkToNonEmptyArray
{
    //Prepare test case
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    [[[mockLink stub]andReturn:@"self"]rel];
    [[[niceMockParser stub]andReturn:mockLink]createLinkFromXML:OCMOCK_ANY type:[EntryLink class]];
    
    //Call test method
    NSMutableArray* links = [NSMutableArray arrayWithObject:[OCMockObject mockForProtocol:@protocol(Link)]];
    [niceMockParser storeLinks:[OCMockObject mockForClass:[CXMLElement class]] item:links type:[EntryLink class]];
    
    //Check results
    GHAssertTrue([links count] == 2, @"");
    GHAssertEquals(mockLink, [links objectAtIndex:1], @"");
}

@end
