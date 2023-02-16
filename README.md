## Gmail Notification

A tiny Gmail client for Mac to retrieve notifications. 

### Backstory

I think browser is already the best Gmail client, but I couldn't be notified of the new email if I don't open the browser. The desktop notification in Gmail's setting doesn't work for me, so I decided to write an app which could inform me when I have new email, that's it.

A week ago I knew nothing about [Swift](https://developer.apple.com/swift/) / [SwiftUI](https://developer.apple.com/xcode/swiftui/) / [AppKit](https://developer.apple.com/documentation/appkit/), but now I succeeded in making this tiny app out. Thougn I'm pretty sure there are a lot of bugs in it, it works! That's enough for me.

## Installation

You need to follow [Oauth2](https://developers.google.com/identity/sign-in/ios/start-integrating) to generate your own `Info.plist` and add your gmail account to the whitelist.

Apply for serving this app to all users seems quite troublesome according to Google's [requirement](https://support.google.com/cloud/answer/9110914), maybe I'll do this later and release a .dmg version.

## User Manual

![image](https://user-images.githubusercontent.com/9478533/219503119-603ad7de-3286-4f39-a622-98a026f036f6.jpg)

#### App Status

The  **G** on the top-left corner displays the app status:

![#53ea11](https://placehold.co/15x15/53ea11/53ea11.png) : You are successfully signed in.

![#ff8002](https://placehold.co/15x15/ff8002/ff8002.png) : Gmail restores your session using the keychain, if it fails to restore, you need to check your network / restart app / click + to sign in again.

![#ff0000](https://placehold.co/15x15/ff0000/ff0000.png) : You are signed out / disconnected.

#### App Theme

The **Moon** beside the title is used to change app theme, currently light / dark mode is available.

#### Open Gmail

The **Envelop** on the top-right corner is used to open Gmail in browser.

#### Avatar

Fetching avatar is asynchronouse, if it fails, you can click the avatar circle to fetch it again.

#### Name && Email Address

As displayed.

#### Count of unread emails

The **Number** indicates how many emails are unread.

![#53ea11](https://placehold.co/15x15/53ea11/53ea11.png) indicates your connection to Gmail api is successful.

![#ff0000](https://placehold.co/15x15/ff0000/ff0000.png) indicates your connection to Gmail api is failed, usually you can ignore this because once your network recovers, it'll turn green again.

#### Plus Button

Click it to get authorization from Gmail, also you can get another account's authorization.

#### Bug Button

Click it to raise an issue / donate / etc.

#### Exit Button

Exit the app.

## Others

This app is based on Google's [GIDSignIn](https://developers.google.com/identity/sign-in/), it only supports one account. If you need to support multiple accounts, [GTMAppAuth](https://github.com/google/GTMAppAuth) is a choice. Cause I don't have plenty of time now, maybe I'll support this later.

## Donate

If you find this app helpful, you can buy me a coffee.

**AliPay:** <br><br>
<img src="https://user-images.githubusercontent.com/9478533/219503117-506d32df-9ba3-42c0-98c7-a49917efabbf.jpg"  width="200" height="200">    

**Wechat:** <br><br>
<img src="https://user-images.githubusercontent.com/9478533/219503122-5b8f0a61-598f-46b0-8312-6c7bd2b1270c.jpg"  width="200" height="200">    

**Paypal(Click):** <br><br>
[<img src="https://user-images.githubusercontent.com/9478533/219503121-999e63fc-df03-4454-897f-1f415e130327.jpg" width="200" height="50">](https://paypal.me/CrayonApe)  











