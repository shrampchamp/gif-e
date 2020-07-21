# GIF-E

GIF-E is a full-featured Giphy search app. The app will search as you type, compose the gifs in a "waterfall" layout, allow you to view a GIF fullscreen, and gives options to save the GIF to your photo library or copy it. It supports iPhone and iPad, Dark Mode and Light Mode, and multiple windows. In the interests of development time, the deployment target was set to iOS 13.

## Instructions

If you'd like to run this app: 

(Dependencies are managed with CocoaPods. However, they checked into Git, so there should be no need to run `pod install`)

1. Open `GIF-E.xcworkspace`
2. Navigate to `GiphyRequest` and find the varible `parameters`. Fill in the `api_key` value with your API key
3. Navigate to the `GIF-E` target and under the `Signing & Capabilities` tab, change the "Team" to a team you belong to 
4. Choose a target device or simulator
5. Run


## Overview

The main view controller is `GIFSearchViewController`, this handles the user search query, requesting results from the Giphy API, displaying them, requesting additional pages of results, and handling behavior when a user taps on a GIF. `GIFDetailViewController` displays a GIF fullscreen and handles functionality to save or copy the GIF. The networking layer (`API` and `APIRequest`) is a pattern I've used previously. Honestly, it's a bit overkill for a project that only needs to interact with one endpoint, but it's my preferred way to set up networking with `Codable` models. `GIF` is the main model and includes child model `Image` that represents the various sizes available. `GiphyResponse` models Giphy's response schema and includes a child `GiphyPagination` model for pagination data. I've used some example code from John Sundell to safely convert the number strings from the Giphy API into actual numbers. 


## Improvements

If I continued to work on this project, I'd first find a replacement for SwiftyGif. It's rare, but some GIFs fail to animate. The image `Data` not play nice with `UIActivityViewController`. I suspect it may be altering the image `Data` or transforming it in some way, although I did not have time to investigate. I'd have to research solutions, although `FLAnimatedImage` looks promising since it is widely used.

Next I'd set the deployement target to iOS 10 or 11. It's a good idea to support as many iOS versions as possible. Even if it's a lot more work, it's worth it to support as many users as possible.

After that, I'd probably add the Giphy trending endpoint to show trending GIFs when the app launches. At that point I'd likely refactor the app so that there would be separate view controllers for trending and for search.

If I wanted to make this a top-tier app, I'd add the ability to save GIFs locally and the ability to view your saved GIFs, perhaps even search them.