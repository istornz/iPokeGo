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

#define SWITCH_POKEMON      0
#define SWITCH_POKESTOPS    1
#define SWITCH_GYMS         2
#define SWITCH_COMMON       3
#define SWITCH_DISTANCE     4
#define SWITCH_TIME         5
#define SWITCH_TIMETIMER    6

#define SWITCH_NOTIFI_NORM  0
#define SWITCH_NOTIFI_FAV   1

#define MAP_SCALE           0.02

#define TEAM_BLUE           1
#define TEAM_RED            2
#define TEAM_YELLOW         3

#define SPRITESHEET_COLS    7
#define SPRITE_SIZE         65
#define IMAGE_SIZE          32.5

#define SERVER_API_DATA     @"%%server_addr%%/raw_data?pokemon=%%pokemon_display%%&pokestops=%%pokestops_display%%&gyms=%%gyms_display%%"
#define SERVER_API_LOCA     @"%%server_addr%%/next_loc?lat=%%latitude%%&lon=%%longitude%%"

#endif /* global_h */
