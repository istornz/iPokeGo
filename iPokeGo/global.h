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

#define SERVER_API_DATA     @"%%server_addr%%/raw_data?pokemon=%%pokemon_display%%&pokestops=%%pokestops_display%%&gyms=%%gyms_display%%"
#define SERVER_API_LOCA     @"%%server_addr%%/next_loc?lat=%%latitude%%&lon=%%longitude%%"

#endif /* global_h */
