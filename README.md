
# Pokemap client for iOS [![Build Status](https://travis-ci.org/istornz/iPokeGo.svg?branch=master)](https://travis-ci.org/istornz/iPokeGo) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.me/istornz)
This is a client for the Pokemap server (https://github.com/PokemonGoMap/PokemonGo-Map)

<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo7.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo6.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo3.jpg" width="270" height="480"/>

## Features
- Show/Hide Pokemons,Pokestops and Gyms.
- Change radar position.
- Drive destination to capture a specific pokemon (bike, walk and transit).
- Notification on status bar when a new pokemon was added on the map.
- Real notification working on iDevice and Apple Watch.
- Possibility to make a favorite list of pokemon (when a favorite pokemon was added on map, a notification more visible is fired).
- Add any server (heroku, your server, jelastic and more...).
- See distance and remaining time on each pokemons.
- Possibility to show/hide common pokemon in a list.
- Supports [**PokemonGo-Map**](https://github.com/PokemonGoMap/PokemonGo-Map) and [**Pogom**](https://github.com/favll/pogom) server.
- Possibility to follow user location.

## Now with real push notification !
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/iPokeGo5.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/screenshots/applewatch/iPokeGOWatch2.png" width="230" height="422"/>

With the latest version of iPokeGO, you can be notified when a new pokemon appear anywhere. It's now possible to play Pokemon GO and be directly warned !

Of course notification works well on the Apple Watch !

You will have no more reason of all not to catch them ;)

## Installation
1. Download the latest IPA file.
2. Download [Cydia impactor](http://www.cydiaimpactor.com/) available for Mac/Windows and Linux.
3. Connect your iDevice to your computer.
3. Open Cydia impactor and drag the ipa file into the window.
4. Enter your Apple ID email address and click "OK".
5. Input your Apple ID password and click "OK" too.
6. The app is now installed on your device but you can't launch it, so go in "Settings" app, "General" tab and "Device Management".
7. Tap the new profile created and trust it.
8. You are now able to run the app on your device !

## Configuration
On settings, please enter the address of your server.

Warning <img src="http://www.outsourcing-pharma.com/var/plain_site/storage/images/publications/pharmaceutical-science/outsourcing-pharma.com/clinical-development/ab-science-hit-with-fda-warning-letter-over-clinical-trials/10077458-1-eng-GB/AB-Science-hit-with-FDA-warning-letter-over-clinical-trials.png" width="20" height="20"/> : "localhost:5000" or "127.0.0.1:5000" are hardware address so it will not work !

To find your address look at this : http://bit.ly/2aweVR1 (if you have a local server) and http://bit.ly/1dWVBmR (if you want to remote server).

## Compatibility
- iDevice : This app works with all iPhone/iPod Touch and iPad, you only need iOS 8 or more.
- Server : Please use latest stable version (https://github.com/PokemonGoMap/PokemonGo-Map/releases)

## TODO
- [x] Add possibility to follow user location (same as website)
- [ ] Add a server status page
- [ ] Regroup pokestops annotations to reduce CPU usage (clustering)
- [x] Update pokestop and gym annotations
- [ ] Find a way to do some background task without hack
- [x] Real notification
- [x] Change scan position

## Others
If you want to edit storyboard file and compile with Xcode 7 on iOS 10 beta, please move the iOS 10 developer image inside Xcode 7 folder [refer to this link](http://stackoverflow.com/a/31013217)

## Android Version
There is an [Android port](https://github.com/omkarmoghe/Pokemap) in the works. All Android related prs and issues please refer to this [repo](https://github.com/omkarmoghe/Pokemap).

## LICENSE
iPokeGo is released under the MIT license. See LICENSE for details.
Thx to @ryanmclachlan for the beautiful UI Design !

#[Official Website] (https://pokemongomap.github.io/PoGoMapWebsite/)
Live visualization of all pokemon (with option to show gyms and pokestops) in your area. This is a proof of concept that we can load all nearby pokemon given a location. Currently runs on a Flask server displaying a Google Map with markers on it.

Using this software is against the ToS and can get you banned. Use at your own risk.

Building off [Mila432](https://github.com/Mila432/Pokemon_Go_API)'s PokemonGo API, [tejado's additions](https://github.com/tejado/pokemongo-api-demo), [leegao's additions](https://github.com/leegao/pokemongo-api-demo/tree/simulation) and [Flask-GoogleMaps](https://github.com/rochacbruno/Flask-GoogleMaps).

---
<a href="https://www.paypal.me/istornz"><img src="http://dimitridessus.fr/img/iPokeGo/buy-me-a-coffee.png" width="170"/></a>

For instructions, please refer to [the wiki](https://pgm.readthedocs.io/en/develop/)
