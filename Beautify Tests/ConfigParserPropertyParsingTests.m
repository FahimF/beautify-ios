//
//  ConfigParserPropertyParsingTests.m
//  Beautify
//
//  Created by Chris Grant on 13/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SCConfigParser_Private.h"
#import "SCTextShadow.h"
#import "UIColor+Comparison.h"
#import "SCStateSetter.h"
#import "SCShadow.h"
#import "SCGradientStop.h"

@interface ConfigParserPropertyParsingTests : XCTestCase
@end

@implementation ConfigParserPropertyParsingTests

#pragma mark - Text Shadows

-(void)testTextShadowFromDictWithValidDict {
    SCTextShadow *shadow = [SCConfigParser textShadowFromDict:@{@"color":@"ffffff", @"offset":@{@"x":@12, @"y":@2}}];
    XCTAssert([shadow.color isEqualToColor:[UIColor whiteColor]], @"Color should be white!");
    XCTAssertEqual(shadow.offset, CGSizeMake(12, 2));
}

-(void)testTextShadowFromDictWithNilDict {
    SCTextShadow *shadow = [SCConfigParser textShadowFromDict:nil];
    XCTAssertNil(shadow, @"Shadow should be nil with a nil dictionary");
}

-(void)testTextShadowFromDictWithNoOffsetDict {
    SCTextShadow *shadow = [SCConfigParser textShadowFromDict:@{@"color":@"ffffff"}];
    XCTAssertNil(shadow, @"Shadow should be nil without an offset");
}

-(void)testTextShadowFromDictWithOnlyOffsetDict {
    SCTextShadow *shadow = [SCConfigParser textShadowFromDict:@{@"offset":@{@"x":@3, @"y":@9}}];
    XCTAssertNotNil(shadow, @"Shadow should not be nil");
    XCTAssertNil(shadow.color, @"We did not specify a color so there shouldn't be one");
    XCTAssertEqual(shadow.offset, CGSizeMake(3, 9), @"Shadow should have an offset of 3,9");
}

#pragma mark - State Setters

-(void)testStateSetterFromDictWithValidDict {
    SCStateSetter *stateSetter = [SCConfigParser stateSetterFromDict:@{@"propertyName" : @"titleShadow",
                                                                       @"state" : @"highlighted",
                                                                       @"value" : @{@"color" : @"FF0000",
                                                                                    @"offset" : @{@"x": @9,
                                                                                                  @"y": @2}
                                                                                    }
                                                                       }];
    XCTAssert(stateSetter.state == UIControlStateHighlighted, @"Should be for the highlighted state");
    XCTAssertEqual(stateSetter.propertyName, @"titleShadow", @"Should be for the title shadow property");
    XCTAssert([stateSetter.value isKindOfClass:[SCTextShadow class]], @"Value should be a text shadow!");
    
    SCTextShadow *shadow = stateSetter.value;
    XCTAssertNotNil(shadow, @"Shadow should not be nil");
    XCTAssert([shadow.color isEqualToColor:[UIColor redColor]], @"Color should be red!");
    XCTAssertEqual(shadow.offset, CGSizeMake(9, 2), @"Shadow should have an offset of 9,2");
}

-(void)testStateSetterFromDictWithoutState {
    SCStateSetter *stateSetter = [SCConfigParser stateSetterFromDict:@{@"propertyName" : @"titleShadow",
                                                                       @"value" : @{@"color" : @"FF0000",
                                                                                    @"offset" : @{@"x": @9,
                                                                                                  @"y": @2}}}];
    XCTAssertNil(stateSetter, @"Should be nil if we don't specify a state");
}

-(void)testStateSetterFromDictWithoutPropertyName {
    SCStateSetter *stateSetter = [SCConfigParser stateSetterFromDict:@{@"state" : @"highlighted",
                                                                       @"value" : @{@"color" : @"FF0000",
                                                                                    @"offset" : @{@"x": @9,
                                                                                                  @"y": @2}}}];
    XCTAssertNil(stateSetter, @"Should be nil if we don't specify a state");
}

#pragma mark - Switch State

-(void)testSwitchStateWithValidDict {
    SCSwitchState *switchState = [SCConfigParser switchStateFromDict:@{@"text" : @"ON",
                                                                       @"textStyle" : @{@"font" : @{@"name" : @"Helvetica-Neue",
                                                                                                    @"size" : @12},
                                                                                        @"color" : @"000000"},
                                                                       @"backgroundColor" : @"0000FF",
                                                                       @"textShadow" : @{@"color" : @"00FF00",
                                                                                         @"offset" : @{@"x": @1,
                                                                                                       @"y": @2}}}];
    
    XCTAssertNotNil(switchState, @"Switch State should not be nil with this valid dictionary");
    XCTAssertEqual(switchState.text, @"ON", @"Switch state should have text ON");
    
    XCTAssert([switchState.textStyle.color isEqualToColor:[UIColor blackColor]], @"Should be black");
    XCTAssertEqual(switchState.textStyle.font.name, @"Helvetica-Neue", @"Should be helvetica-neue");
    XCTAssertEqual(switchState.textStyle.font.size, 12.0f, @"Should be size 12");
    
    XCTAssert([switchState.backgroundColor isEqualToColor:[UIColor blueColor]], @"Should be blue");
    
    XCTAssert([switchState.textShadow.color isEqualToColor:[UIColor greenColor]], @"Should be green");
               
    XCTAssertEqual(switchState.textShadow.offset, CGSizeMake(1, 2), @"Should have offset, 1,2");
}

-(void)testSwitchStateWithoutText {
    SCSwitchState *switchState = [SCConfigParser switchStateFromDict:@{@"textStyle" : @{@"font" : @{@"name" : @"Helvetica-Neue",
                                                                                                    @"size" : @12},
                                                                                        @"color" : @"000000"},
                                                                       @"backgroundColor" : @"0000FF",
                                                                       @"textShadow" : @{@"color" : @"00FF00",
                                                                                         @"offset" : @{@"x": @1,
                                                                                                       @"y": @2}}}];
    
    XCTAssertNotNil(switchState, @"Switch State should not be nil with this valid dictionary");
    
    XCTAssert([switchState.textStyle.color isEqualToColor:[UIColor blackColor]], @"Should be black");
    XCTAssertEqual(switchState.textStyle.font.name, @"Helvetica-Neue", @"Should be helvetica-neue");
    XCTAssertEqual(switchState.textStyle.font.size, 12.0f, @"Should be size 12");
    
    XCTAssert([switchState.backgroundColor isEqualToColor:[UIColor blueColor]], @"Should be blue");
    
    XCTAssert([switchState.textShadow.color isEqualToColor:[UIColor greenColor]], @"Should be green");
    
    XCTAssertEqual(switchState.textShadow.offset, CGSizeMake(1, 2), @"Should have offset, 1,2");
}

-(void)testSwitchStateWithoutTextStyle {
    SCSwitchState *switchState = [SCConfigParser switchStateFromDict:@{@"backgroundColor" : @"0000FF",
                                                                       @"textShadow" : @{@"color" : @"00FF00",
                                                                                         @"offset" : @{@"x": @1,
                                                                                                       @"y": @2}}}];
    
    XCTAssertNotNil(switchState, @"Switch State should not be nil with this valid dictionary");
    
    XCTAssert([switchState.backgroundColor isEqualToColor:[UIColor blueColor]], @"Should be blue");
    
    XCTAssert([switchState.textShadow.color isEqualToColor:[UIColor greenColor]], @"Should be green");
    XCTAssertEqual(switchState.textShadow.offset, CGSizeMake(1, 2), @"Should have offset, 1,2");
}

-(void)testSwitchStateWithNoDictionary {
    SCSwitchState *state = [SCConfigParser switchStateFromDict:nil];
    XCTAssertNil(state, @"State should be nil if the dictionary is nil");
}

#pragma mark - Shadows

-(void)testShadowsFromDictWithValidDict {
    SCShadow *shadow = [SCConfigParser shadowFromDict:@{@"radius": @2,
                                                        @"offset": @{@"x": @3, @"y": @2},
                                                        @"color": @"#0000FF"}];
    
    XCTAssertEqual(2.0f, shadow.radius, @"Shadow radius should be 2");
    XCTAssertEqual(CGSizeMake(3, 2), shadow.offset, @"Offset should be 3, 2");
    XCTAssert([shadow.color isEqualToColor:[UIColor blueColor]], @"Color should be blue");
}

-(void)testShadowsFromDictWithPartialDict {
    SCShadow *shadow = [SCConfigParser shadowFromDict:@{@"radius": @2,
                                                        @"color": @"#0000FF"}];
    XCTAssertEqual(2.0f, shadow.radius, @"Shadow radius should be 2");
    XCTAssertEqual(CGSizeZero, shadow.offset, @"Should be a zero shadow offset if we don't specify one.");
    XCTAssert([shadow.color isEqualToColor:[UIColor blueColor]], @"Color should be blue");
    
    shadow = [SCConfigParser shadowFromDict:@{@"radius": @2}];
    XCTAssertEqual(2.0f, shadow.radius, @"Shadow radius should be 2");
    XCTAssertEqual(CGSizeZero, shadow.offset, @"Should be a zero shadow offset if we don't specify one.");
    XCTAssertNil(shadow.color, @"Color should be nil if we don't specify one");
    
    shadow = [SCConfigParser shadowFromDict:@{@"color": @"00FF00"}];
    XCTAssertEqual(0.0f, shadow.radius, @"Shadow radius should be 0");
    XCTAssertEqual(CGSizeZero, shadow.offset, @"Should be a zero shadow offset if we don't specify one.");
    XCTAssert([shadow.color isEqual:[UIColor greenColor]], @"Color should be green.");
}

-(void)testShadowsFromDictWithInvalidDict {
    SCShadow *shadow = [SCConfigParser shadowFromDict:nil];
    XCTAssertNil(shadow, @"Shadow should be nil if the dictionary is nil");
    
    shadow = [SCConfigParser shadowFromDict:@{@"This is not a shadow" : @"Not"}];
    XCTAssertNil(shadow, @"If the dictionary doesn't have the necessary shadow data, it should return nil");
}

#pragma mark - Gradients

-(void)testValidGradientFromDict {
    SCGradient *gradient = [SCConfigParser gradientFromDict:@{@"radial": @YES,
                                                              @"radialOffset": @{@"x": @20, @"y":@30},
                                                              @"stops":@[@{@"position":@0.1, @"color": @"FF0000"},
                                                                         @{@"position":@0.5, @"color": @"00FF00"},
                                                                         @{@"position":@0.8, @"color": @"0000FF"}]
                                                              }];
    
    XCTAssertEqual(gradient.radial, YES, @"Gradient should be radial");
    XCTAssertEqual(gradient.radialOffset, CGSizeMake(20, 30), @"Radial offset should be 20, 30");
    XCTAssertEqual((NSUInteger)3, gradient.stops.count, @"Should be 3 stops");
    
    SCGradientStop *stop1 = gradient.stops[0];
    SCGradientStop *stop2 = gradient.stops[1];
    SCGradientStop *stop3 = gradient.stops[2];
    
    XCTAssertEqual(stop1.stop, 0.1f, @"Should have a position of 0.1");
    XCTAssert([stop1.color isEqualToColor:[UIColor redColor]], @"Should be a red stop");
    XCTAssertEqual(stop2.stop, 0.5f, @"Should have a position of 0.5");
    XCTAssert([stop2.color isEqualToColor:[UIColor greenColor]], @"Should be a green stop");
    XCTAssertEqual(stop3.stop, 0.8f, @"Should have a position of 0.8");
    XCTAssert([stop3.color isEqualToColor:[UIColor blueColor]], @"Should be a blue stop");
    
    gradient = [SCConfigParser gradientFromDict:@{@"radial": @NO,
                                                   @"stops":@[@{@"position":@0.0, @"color": @"000000"},
                                                              @{@"position":@1.0, @"color": @"FF0000"}]
                                                   }];
    
    XCTAssertEqual(gradient.radial, NO, @"Gradient shouldn't be radial");
    XCTAssertEqual(gradient.radialOffset, CGSizeZero, @"Radial offset should 0,0");
    XCTAssertEqual((NSUInteger)2, gradient.stops.count, @"Should be 2 stops");
    
    stop1 = gradient.stops[0];
    stop2 = gradient.stops[1];
    
    XCTAssertEqual(stop1.stop, 0.0f, @"Should have a position of 0.0");
    XCTAssert([stop1.color isEqualToColor:[UIColor blackColor]], @"Should be a black stop");
    XCTAssertEqual(stop2.stop, 1.0f, @"Should have a position of 1.0");
    XCTAssert([stop2.color isEqualToColor:[UIColor redColor]], @"Should be a red stop");
}

-(void)testGradientFromDictWithPartialDict {
    SCGradient *gradient = [SCConfigParser gradientFromDict:@{@"radialOffset": @{@"x": @20, @"y":@30},
                                                              @"stops":@[@{@"position":@0.1, @"color": @"FF0000"},
                                                                         @{@"position":@0.5, @"color": @"00FF00"},
                                                                         @{@"position":@0.8, @"color": @"0000FF"}]
                                                              }];
    XCTAssertNil(gradient, @"If we don't specify radial, gradient should always be nil");
    
    gradient = [SCConfigParser gradientFromDict:@{@"radialOffset": @{@"x": @20, @"y":@30},
                                                  @"radial": @NO}];
    XCTAssertNil(gradient, @"If we don't specify stops, gradient should always be nil");
}

-(void)testGradientFromDictWithInvalidDict {
    SCGradient *gradient = [SCConfigParser gradientFromDict:nil];
    XCTAssertNil(gradient, @"Gradient should be nil if the dictionary is nil");
    
    gradient = [SCConfigParser gradientFromDict:@{}];
    XCTAssertNil(gradient, @"Gradient should be nil if the dictionary doesn't have the neccesary data");
    
    gradient = [SCConfigParser gradientFromDict:@{@"This is not a gradient" : @"Shouldnt be able to parse it!"}];
    XCTAssertNil(gradient, @"Gradient should be nil if the dictionary doesn't have the neccesary data");
}

@end