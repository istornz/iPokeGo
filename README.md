
# Pokemap client for iOS [![Build Status](https://travis-ci.org/istornz/iPokeGo.svg?branch=master)](https://travis-ci.org/istornz/iPokeGo)
This is a client for the Pokemap server (https://github.com/AHAAAAAAA/PokemonGo-Map)

<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo4.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo6.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo3.jpg" width="270" height="480"/>

## Features
- Show/Hide Pokemons,Pokestops and Gyms.
- Change radar position.
- Drive destination to capture a specific pokemon.
- Notification on status bar when a new pokemon was added on the map.
- Real notification working on iDevice and Apple Watch.
- Possibility to make a favorite list of pokemon (when a favorite pokemon was added on map, a notification more visible is fired).
- Add any server (heroku, your server, jelastic and more...).
- See distance and remaining time on each pokemons.
- Possibility to show/hide common pokemon in a list.

## Now with real push notification !
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo5.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/applewatch/iPokeGOWatch2.png" width="230" height="422"/>

With the latest version of iPokeGO, you can be notified when a new pokemon appear anywhere. It's now possible to play Pokemon GO and be directly warned !

Of course notification works well on the Apple Watch !

You will have no more reason of all not to catch them ;)

## Installation
1. Install Xcode
2. Open *iPokeGo.xcodeproj* in Xcode
3. Choose your own itunes account under *Signing > Team*
4. Change the identifier in Xcode from 'com.dimitri-dessus.iPokeGo' to something like 'com.YOUR_NAME.iPokeGo'. 
5. Plug in your device and at the top select it in the dropdown
6. Hit the play button it should compile and transfer over to the device pluged in and open
7. If this is the first app you install under your own itunes account you will need to approve it. On your device under *Setting > General > Profiles* click trust.
8. Unplug and enjoy the app

## Configuration
On settings, please enter the address of your server.

Warning <img src="http://www.outsourcing-pharma.com/var/plain_site/storage/images/publications/pharmaceutical-science/outsourcing-pharma.com/clinical-development/ab-science-hit-with-fda-warning-letter-over-clinical-trials/10077458-1-eng-GB/AB-Science-hit-with-FDA-warning-letter-over-clinical-trials.png" width="20" height="20"/> : "localhost:5000" or "127.0.0.1:5000" are hardware address so it will not work !

To find your address look at this : http://bit.ly/2aweVR1 (if you have a local server) and http://bit.ly/1dWVBmR (if you want to remote server).

## Compatibility
- iDevice : This app works with all iPhone/iPod Touch and iPad, you only need iOS 8 or more.
- Server : Please use latest stable version (https://github.com/AHAAAAAAA/PokemonGo-Map/tree/V2.0)

## TODO
- [ ] Make the app totaly independent
- [ ] Regroup pokestops annotations to reduce CPU usage (clustering)
- [ ] Update pokestop and gym annotations
- [ ] Find a way to do some background task without hack
- [x] Real notification
- [x] Change scan position

## Android Version
There is an [Android port](https://github.com/omkarmoghe/Pokemap) in the works. All Android related prs and issues please refer to this [repo](https://github.com/omkarmoghe/Pokemap).

## LICENSE
iPokeGo is released under the MIT license. See LICENSE for details.
Thx to @ryanmclachlan for the beautiful UI Design !

#[Official Website] (https://jz6.github.io/PoGoMap/#)
Live visualization of all pokemon (with option to show gyms and pokestops) in your area. This is a proof of concept that we can load all nearby pokemon given a location. Currently runs on a Flask server displaying a Google Map with markers on it.

Using this software is against the ToS and can get you banned. Use at your own risk.

Building off [Mila432](https://github.com/Mila432/Pokemon_Go_API)'s PokemonGo API, [tejado's additions](https://github.com/tejado/pokemongo-api-demo), [leegao's additions](https://github.com/leegao/pokemongo-api-demo/tree/simulation) and [Flask-GoogleMaps](https://github.com/rochacbruno/Flask-GoogleMaps).

---
For instructions, please refer to [the wiki](https://github.com/AHAAAAAAA/PokemonGo-Map/wiki)
