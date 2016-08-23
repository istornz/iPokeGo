//
//  global.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#ifndef global_h
#define global_h

#define POKEMON_NUMBER      151
#define DEFAULT_RADIUS      120

#define SELECT_FAVORITE	    0
#define SELECT_COMMON       1

#define SWITCH_NOTIFI_NORM  0
#define SWITCH_NOTIFI_FAV   1
#define SWITCH_VIBRATION    2

#define MAP_SCALE           0.02
#define MAP_SCALE_ANNOT     0.001

#define TEAM_BLUE           1
#define TEAM_RED            2
#define TEAM_YELLOW         3

#define COLOR_COMMON        [UIColor colorWithRed:0.72 green:0.72 blue:0.82 alpha:1.0]
#define COLOR_UNCOMMON      [UIColor colorWithRed:0.54 green:0.54 blue:0.35 alpha:1.0]
#define COLOR_RARE          [UIColor colorWithRed:0.94 green:0.50 blue:0.19 alpha:1.0]
#define COLOR_VERYRARE      [UIColor colorWithRed:0.75 green:0.19 blue:0.16 alpha:1.0]
#define COLOR_ULTRARARE     [UIColor colorWithRed:0.63 green:0.25 blue:0.63 alpha:1.0]

#define TEAM_COLOR_BLUE     [UIColor colorWithRed:0.41 green:0.56 blue:0.94 alpha:1.0]
#define TEAM_COLOR_RED      [UIColor colorWithRed:0.75 green:0.19 blue:0.16 alpha:1.0]
#define TEAM_COLOR_YELLOW   [UIColor colorWithRed:0.97 green:0.82 blue:0.19 alpha:1.0]
#define TEAM_COLOR_GRAY     [UIColor colorWithRed:0.15 green:0.20 blue:0.23 alpha:1.0]

#define NOTIF_FOLLOW_GREEN_COLOR    [UIColor colorWithRed:0.10 green:0.74 blue:0.61 alpha:1.0]
#define NOTIF_FOLLOW_RED_COLOR      [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0]

#define SERVER_API_DATA_POKEMONGOMAP    @"%%server_addr%%/raw_data?pokemon=%%pokemon_display%%&pokestops=%%pokestops_display%%&gyms=%%gyms_display%%&spawnpoints=%%spawnpoints_display%%&ids=%%idlist%%"
#define SERVER_API_DATA_SCAN_LOCATION   @"%%server_addr%%/loc"
#define SERVER_API_DATA_POGOM           @"%%server_addr%%/map-data?pokemon=%%pokemon_display%%&gyms=%%gyms_display%%"

#define SERVER_API_LOCA_POKEMONGOMAP    @"%%server_addr%%/next_loc?lat=%%latitude%%&lon=%%longitude%%"
#define SERVER_API_LOCA_POGOM           @"%%server_addr%%/location?lat=%%latitude%%&lng=%%longitude%%&radius=%%radius%%"

#define SERVER_API_LOCAREMOVE_POGOM     @"%%server_addr%%/location?lat=%%latitude%%&lng=%%longitude%%"

#endif /* global_h */
