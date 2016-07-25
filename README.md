
# Pokemap client for iOS [![Build Status](https://travis-ci.org/istornz/iPokeGo.svg?branch=master)](https://travis-ci.org/istornz/iPokeGo)
This is a client for the Pokemap server (https://github.com/AHAAAAAAA/PokemonGo-Map)

<img src="http://dimitridessus.fr/img/iPokeGo/iPokeGo4.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/iPokeGo2.jpg" width="270" height="480"/>
<img src="http://dimitridessus.fr/img/iPokeGo/iPokeGo3.jpg" width="270" height="480"/>

## Features
- Show/Hide Pokemons,Pokestops and Gyms
- Change radar position
- Drive destination to capture a specific pokemon
- Notification on status bar when a new pokemon was added on the map
- Possibility to make a favorite list of pokemon (when a favorite pokemon was added on map, a notification more visible is fired)
- Add any server
- Possibility to show/hide very common pokemon like (Rattata, Pidgey, Zubat, Drowzee)

## Installation
1. Install **Xcode 8 beta** <https://developer.apple.com/download/>
2. Open *iPokeGo.xcodeproj* in Xcode
3. Choose your own itunes account under *Signing > Team*
4. Plug in your device and at the top select it in the dropdown
5. Hit the play button it should compile and transfer over to the device pluged in and open
6. If this is the first app you install under your own itunes account you will need to approve it. On your device under *Setting > General > Profiles* click trust.
7. unplug and enjoy the app

## Compatibility
This app works with all iPhone/iPod Touch and iPad, you only need iOS 8 or more.

## TODO
- [ ] Make the app totaly independent
- [x] Change scan position

## Android Version
There is an [Android port](https://github.com/omkarmoghe/Pokemap) in the works. All Android related prs and issues please refer to this [repo](https://github.com/omkarmoghe/Pokemap).

## LICENSE
iPokeGo is released under the MIT license. See LICENSE for details.

#[Official Website] (https://jz6.github.io/PoGoMap/#)
Live visualization of all pokemon (with option to show gyms and pokestops) in your area. This is a proof of concept that we can load all nearby pokemon given a location. Currently runs on a Flask server displaying a Google Map with markers on it.

Using this software is against the ToS and can get you banned. Use at your own risk.

Building off [Mila432](https://github.com/Mila432/Pokemon_Go_API)'s PokemonGo API, [tejado's additions](https://github.com/tejado/pokemongo-api-demo), [leegao's additions](https://github.com/leegao/pokemongo-api-demo/tree/simulation) and [Flask-GoogleMaps](https://github.com/rochacbruno/Flask-GoogleMaps).

---
For instructions, please refer to [the wiki](https://github.com/AHAAAAAAA/PokemonGo-Map/wiki)
