##Inspiration
In the United States alone, over 100,000 missing persons requests go dark every year, and leave law enforcement with little to no choice but to abandon their efforts as resources/time start to diminish. Current statistics indicate that after the initial 48 hours of a missing persons event have passed, recovery decreases by 50%. Even worse, law enforcement may sometimes have little or no information to begin their search. We aim to solve that problem, by crowd sourcing the millions of images taken everyday we can paint a picture of their potential whereabouts or last seen whereabouts.

##What it does
Images are scanned using facial recognition for a match to an image in the missing persons database, and in the case of a match a geolocation is estimated and sent back to desktop software (which would be used by law enforcement to act on this data).

##How we built it
There were three main layers we had to build:

Desktop UI (mainly for law enforcement professionals)
Mobile application (for community members wishing to participate in the program)
Google Cloud server (does the core amount of work, waits for uploaded images to our storage bucket then as new images come in compares them with known images in the missing persons database using facial recognition)
At a lower level, we used ElectronJS to build a desktop UI for law enforcement to use (they always have a laptop around). From here images could be uploaded to the public database, which consisted of a Firebase storage bucket. Our middleware, a Google Cloud server would scan images taken by users and compare them to images in the storage bucket using Microsoft's Facial Recognition API. High confidence matches would be sent back to the desktop UI with a geotag regarding location of the previous image, in the case where there are multiple hits the most recent information is returned.

##Challenges we ran into
API calls/requests are always fun to mess around with, but we did have a problem setting up our Google Cloud endpoints.

##Accomplishments that we're proud of
Each of us learned a new platform that we previously didn't know before, for example ElectronJS or Flutter.io. We were also able to get a very basic implementation of our project running.

##What we learned
We learned Electron, Flutter, more about API calls/requests. How important communication is in a multi-level project that spans 3 different technologies.

##What's next for Go Find Me
Find more incentives for people to join the program, potentially use social media pictures as well. Add cleaner UI, and endpoints need to be updated.
