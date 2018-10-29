# Twilio Chat Tutorial for Swift
[![Build Status](https://travis-ci.org/TwilioDevEd/twiliochat-swift.svg?branch=master)](https://travis-ci.org/TwilioDevEd/twiliochat-swift)

Swift implementation of Twilio Chat

### Running the Application

1. Clone the repository and `cd` into it
1. Install the application's dependencies with [CocoaPods](https://cocoapods.org/)

   ```bash
   $ pod install
   ```
1. Open the project with `Xcode` but don't use `twiliochat.xcodeproj` file. For
   CocoaPods dependencies to work you must use `twiliochat.xcworkspace`.
1. [Twilio Chat](https://www.twilio.com/docs/chat) requires an
   [access token](https://www.twilio.com/docs/chat/identity) generated using your
   Twilio credentials in order to connect. First we need to setup a server that will generate this token
   for the mobile application to use. We have created web versions of Twilio Chat, you can use any of these
   applications to generate the token that this mobile app requires. Just pick your favorite flavor:

   * [PHP - Laravel](https://github.com/TwilioDevEd/twiliochat-laravel)
   * [C# - .NET MVC](https://github.com/TwilioDevEd/twiliochat-csharp)
   * [Java - Servlets](https://github.com/TwilioDevEd/twiliochat-servlets)
   * [JS - Node](https://github.com/TwilioDevEd/twiliochat-node)

   Look for instructions on how to setup these servers in any of the links above.

1. Once you have the server running (from the previous step), you need to edit one
   file in the Xcode project.

   ```
   ProjectRoot -> twiliochat -> resources -> Keys.plist
   ```
   This file contains the `TokenRequestUrl` key. The default value is `http://localhost:8000/token`. This
   address refers to the host machine loopback interface when running this application
   in the iOS simulator. You must change this value to match the address of your server running
   the token generation application. We are using the [PHP - Laravel](https://github.com/TwilioDevEd/twiliochat-laravel)
   version in this case, that's why we use port 8000.

   ***Note:*** In some operating systems you need to specify the address for the development server
   when you run the Laravel application, here's an example:

   ```
   $ php artisan serve --host=127.0.0.1
   ```

1. Now Twilio Chat is ready to go. Run the application on the simulator or your own device, just
   make sure that you have properly set up the token generation server and the `TokenRequestUrl` key.
   To run the application in a real device you'll need to expose your local token generation server
   by manually forwarding ports, or using a tool like [ngrok](https://ngrok.com/).
   If you decide to work with ngrok, your Keys.plist file should hold a key like this one:

   ```
   TokenRequestUrl -> http://<your_subdomain>.ngrok.io/token
   ```
   No need to specify the port in this url, as ngrok will forward the request to the specified port.
