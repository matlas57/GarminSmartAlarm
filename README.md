# Garmin Watch Smart Alarm App
I wear a Garmin watch that I got originally to track my runs, but it has also become my alarm clock. I set a time and it wakes me up at that time. The watch also collects various biometric data like heart rate, movement, respiratory rate, etc. This data can be used to gauge what stage of sleep one is in. This app is to merge these features, use biometric data to intelligently wake up the user at a time where they can be woken up without any disorientation or grogginess. 

# Flow of the App
1. The app will prompt the user for a time interval in which they permit to be woken up.
2. During the provided interval the app will estimate the user's sleep stage, aiming to wake up the user during light (N1, N2) sleep.

# Some Later Features to Come
1. Using user recovery to wake up the user sooner or later, depending on if the app believes that the user is fully recovered or can use some more time asleep.
2. Collect data about how quickly user recovers based on estimated sleep quality, then can automatically set alarms for optimal sleep time.
