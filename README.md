# terco_app

Aplicativo rezar o terço. Pray the Rosary app.
This application is aimed to play the prayers of the Rosary.
It is made in Flutter.

# Guidance
This app should be quite straightforward in its use.
For now, it will work only in Portuguese, but let it be ready to support other languages too.
Should support white and dark themes, detecting the system theme to follow.
The source audio files for the prayers and misteries are inside media_src/pt folder. "pt" 
indicates portuguese language.
The user cannot change the order the audio files are played, because the Rosary has a fixed 
order and procedure.

## First screen
Should present media control buttons spotlighted: play, pause, next, previous and reproduction 
speed (0.5x, 0.75x, 1x - default -, 1.25x, 1.5x, 2x). They should be big to ease the use when 
driving.
Below, there should be a list of Rosary misteries - listed in misterios.md file - and 
corresponding to the week day the app should pre-select the correct set of misteries to be prayed.
The user can, however, select another one.
By the side of the media controls, there can be a little UI feedback pointing which part of the 
Rosary the user is: the dot representing a prayer, for example.

# How is the Rosary prayed (guidance for the app workflow and applied for each day of the week).
## Apendix - beginning
First make the sign of the Cross.
Pray/play the "Credo" - The Apostles' Creed.
Pray/play the "Pai nosso - Our Father".
Pray/play three "Ave Maria - Hail Mary".
Pray/play the "Glória - Glory be to the Father".

## First mistery
Plays the audio corresponding to that mistery title and description. Example: "Primeiro Mistério 
Gozoso: Anunciação a Maria" and "No sexto mês, o anjo Gabriel foi enviado por Deus a uma 
cidade da Galiléia, chamada Nazaré,  a uma virgem desposada com um homem que se chamava José, da 
casa de Davi e o nome da virgem era Maria".
Let some 15 secs for meditation (configurable).
Play the Pai Nosso prayer.
Play Ave Maria prayer 10 times straight.
Play the Glória.

## Second mistery
Plays the audio corresponding to that mistery title and description.
Let some 15 secs for meditation (configurable).
Play the Pai Nosso prayer.
Play Ave Maria prayer 10 times straight.
Play the Glória.

## Third mistery
Plays the audio corresponding to that mistery title and description.
Let some 15 secs for meditation (configurable).
Play the Pai Nosso prayer.
Play Ave Maria prayer 10 times straight.
Play the Glória.

## Fourth mistery
Plays the audio corresponding to that mistery title and description.
Let some 15 secs for meditation (configurable).
Play the Pai Nosso prayer.
Play Ave Maria prayer 10 times straight.
Play the Glória.

## Fifth mistery
Plays the audio corresponding to that mistery title and description.
Let some 15 secs for meditation (configurable).
Play the Pai Nosso prayer.
Play Ave Maria prayer 10 times straight.
Play the Glória.

## Finishing
Play the Salve Rainha.
Finish with the Sign of the Cross.
