---
title: Introduction to JavaScript scripting inside Spectator
description: Enhance your requests with scripting
---

<h2 class="subtitle is-2 content">Select the script tab</h2>

Get to the scripting section by clicking on the script tab inside the request view.

<img class="guide-image shadow" src="/scripting/select_scripting.png">

<h2 class="subtitle is-2 content">Extend your own request</h2>

You will see a scripting view with outcommented code. At the bottom right are two buttons, the left for
accessing this document, the right for opening the scripting console.
<img class="guide-image" src="/scripting/scripting_view.png">

Open the scripting console by clicking on the right button in the bottom right.
Remove the comments of the function by removing the `//` at the front and add `console.log("Some text");`
to the function body. The terminal will now display the message of your script.

<img class="guide-image" src="/scripting/basic_logging.png">

The request object which is passedd to the `before_sending` function is exactly the same the one which you're
configuring in the request view. You can alter the request here before it is finally sent.

To verify that the request is indeed the same request log the JSON representation of your string to the console.
To get the JSON representation of your request just use the `JSON.stringify` function on your request object.

<img class="guide-image" src="/scripting/request_logging.png">

The scripting engine is also able to do HTTP requests.
<a href="/docs/scripting/build_in">The Build-In section has more information about HTTP</a>

To get started, just make a GET-request to `https://jsonplaceholder.typicode.com/photos/5` by using `HTTP.get`, store the response in a variable
and log it to the console by using `JSON.stringify`.

<img class="guide-image" src="/scripting/http_request.png">