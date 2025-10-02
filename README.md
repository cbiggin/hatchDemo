#  HatchDemo

This is the archive for an app developed for Hatch Innovations.

Currently, the app has 2 tabs:
- Editing Tab
- Scrolling Tab

The `Editing` tab contains the `UITextView` sub-class control (called `CBExpandingTextView`) which demonstrates the text view expanding as you type (to a maximum of 5 lines). This is actually Task 2 but it's in the first tab

The `Scrolling` tab contains the infinite scrolling of videos. This is Task 1,

### Implementation of Video Scrolling

Initially I implemented it with `UITableView` (just to get something working and testing). But of course, `UITableView` is constrained and you have to specify a number of cells.

To get around this, I just used a "swappable" list of views (containing an `AVPlayer`) and just animated swiping up/down. Couple of things:

- I randomly grab a url from the manifest that is initially downloaded

- As you scroll down, the list will automatically add another random entry from the manifest-urls

- I display the index (and count) in the top-right of the screen


### Architecture & Decisions

I use a `Services` based approach so I use use `Services.api` and download the initial manifest. Anybody interested in it (ie, `ScrollingVC`) will then just subscribe to:

    Services.api.videoUrls

### To Do

Right now, it's Thursday afternoon at 1:30pm and I'll try to add the following:

- 3rd tab: will contain the expanding text view over the video scroller

- Network monitoring. Will be another `Service`.
