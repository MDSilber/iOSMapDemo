//
//  PlaceMapViewController.m
//  MapDemo
//
//  Created by Mason Silber on 2/28/13.
//  Copyright (c) 2013 Mason Silber. All rights reserved.
//

#import "PlaceMapViewController.h"
#import "Place.h"
#import "MapPin.h"

#define startLat @"40.809881"
#define startLong @"-73.959746"
#warning Add your own oauth token from foursquare, which you can get from the API docs
#define token @"Q40VXHQ1MMW1VV3DKS3RUVEFQPFPY1KYGNDUGCLZ5IZF2EMD"

@interface PlaceMapViewController ()

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) NSMutableArray *placeArray;

@end

@implementation PlaceMapViewController

@synthesize map = _map;
@synthesize placeArray = _placeArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _placeArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _map = [[MKMapView alloc] initWithFrame:[[self view] frame]];
    [_map setDelegate:self];
    
    CLLocationCoordinate2D startLocation;
    startLocation.latitude = [startLat floatValue];
    startLocation.longitude = [startLong floatValue];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(startLocation, span);
    [_map setRegion:region];
    
    [[self view] addSubview:_map];
	// Do any additional setup after loading the view.
}

-(void)getPlacesForLocation:(CLLocationCoordinate2D)location
{
    NSString *formattedLat = [NSString stringWithFormat:@"%0.2f", location.latitude];
    NSString *formattedLong = [NSString stringWithFormat:@"%0.2f", location.longitude];
    NSURL *placesURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&oauth_token=%@&v=20130228", formattedLat, formattedLong, token]];
    NSLog(@"%@",[placesURL absoluteString]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
                   {
                       NSError *error = nil;
                       NSData *placeData = [NSData dataWithContentsOfURL:placesURL options:0 error:&error];
                       if(error)
                       {
                           NSLog(@"Error getting data: %@", [error description]);
                           return;
                       }
                       NSDictionary *placesDict = [NSJSONSerialization JSONObjectWithData:placeData options:0 error:&error];
                       if(error)
                       {
                           NSLog(@"Error parsing data: %@", [error description]);
                           return;
                       }
                       NSArray *placesArray = [[placesDict objectForKey:@"response"] objectForKey:@"venues"];
                       for(NSDictionary *placeDict in placesArray)
                       {
                           Place *newPlace = [[Place alloc] init];
                           [newPlace setName:[placeDict objectForKey:@"name"]];
                           [newPlace setAddress:[[placeDict objectForKey:@"location"] objectForKey:@"address"]];
                           
                           CLLocationCoordinate2D placeLocation;
                           placeLocation.latitude = [[[placeDict objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                           placeLocation.longitude = [[[placeDict objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                           [newPlace setLocation:placeLocation];
                           
                           [_placeArray addObject:newPlace];
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [self putPinsOnMap];
                                      });
                   });
}

-(void)putPinsOnMap
{
    for(Place *place in _placeArray)
    {
        MapPin *pin = [[MapPin alloc] init];
        [pin setTitle:[place name]];
        [pin setSubtitle:[place address]];
        [pin setCoordinate:[place location]];
        [_map addAnnotation:pin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate methods

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if([_placeArray count] == 0)
    {
        [self getPlacesForLocation:[_map centerCoordinate]];
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *identifier = @"MapPin";
    if([annotation isKindOfClass:[MapPin class]])
    {
        MKPinAnnotationView *newPin = (MKPinAnnotationView *)[_map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if(newPin == nil)
        {
            newPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        else
        {
            [newPin setAnnotation:annotation];
        }
        
        [newPin setEnabled:YES];
        [newPin setPinColor:MKPinAnnotationColorRed];
        [newPin setCanShowCallout:YES];
        [newPin setAnimatesDrop:YES];
        return newPin;
    }
    return nil;
}

@end
