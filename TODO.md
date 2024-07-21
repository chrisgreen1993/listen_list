# TODO

## In progress

[] More complex logic around detecting valid posts [feat]
    [] E.g (Artist- Album) (Artist -- Album)
    [x] Can we extract more data out of the raw post
     - Spotify embed description has these formats: 
       - Listen to [ALBUM] on Spotify. [ARTIST] · [TYPE] · 2024 · 11 songs.
       - [ALBUM], an [TYPE?] by [ARTIST] on Spotify
     - Bandcamp embed description has these formats: 
        - [ALBUM] by [ARTIST], released 24 May 2024[NUMBERED LIST OF TRACKS]
        - [ALBUM] by [ARTIST], releases 24 May 2024 [NUMBERED LIST OF TRACKS]
    [] Update existing releases that are in review with album and artist from embed.


## Next

## Backlog

[] Add r/hiphopheads and r/popheads
[] See more releases for each period (a seperate page?) [feat]
[] Save functionality (localstorage initially?)

## Done

[x] Refactor Music context [refactor]
    [] Move queries within module? (I think it's fine as is rn)
    [x] Rename context to Releases?
    [x] Macros in separate module
[x] Weekly emails [feat]
    [x] Remove GenServer and use a scheduler that allows specific times.
    [x] Choose email service (SES, postmark, sendgrid)
    [x] Implement email confirmation
    [x] Implement weekly email sending 
    [x] Implement email unsubscribe
    [x] Setup Mailgun + templates
    [x] Setup Mailgun in prod
[x] CLI for reviewing imported releases [feat]
    [x] List releases that need reviewing
    [x] Update release data and set status (manual / rejected)
[x] CI / deployment pipeline [feat]
    [x] deployment
    [x] tests
[x] Rename fetch releases to import [refactor]
[x] Tidy UI into components [refactor]
[x] Remove nsfw & self in thumbnail url [bug]
[x] Modal / page for individual release [feat]
    [x] Display embed
    [x] Link to url / reddit url
    [x] Add column for embed
[x] Domain [feat]
[x] Display releases grouped by each week, month, etc [feat]
    [x] Backend work to group releases
    [x] Date formatting
    [x] Navigate to next release
[x] Import data into fly db [feat]
