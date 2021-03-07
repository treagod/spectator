---
title: Built-Ins of Spectator scripting
description: Overview of Spectator scripting build-ins
---

<h2 class="subtitle is-2 content">Overview</h2>

The Spectator scripting engines provides some common and some new built-in functions. This documentation lists the built-ins
and the API.

<h3 class="subtitle is-3 content">Module HTTP</h3>
<h4 class="subtitle is-4">Function <code>get</code></h4>

`HTTP.get` makes a GET-request. <br><br>

**Arguments:**

url : String - Destination of the request

**Returns:**

response : Response

<h4 class="subtitle is-4">Function <code>post</code></h4>

`HTTP.post` makes a POST-request. <br><br>

**Arguments:**

url : String - Destination of the request
headers : Object - Header List

**Returns:**

response : Response

<h4 class="subtitle is-4">Function <code>put</code></h4>

`HTTP.put` makes a PUT-request. <br><br>

**Arguments:**

url : String - Destination of the request
headers : Object - Header List

**Returns:**

response : Response

<h4 class="subtitle is-4">Function <code>patch</code></h4>

`HTTP.patch` makes a PATCH-request. <br><br>

**Arguments:**

url : String - Destination of the request
headers : Object - Header List

**Returns:**

response : Response

<h4 class="subtitle is-4">Function <code>destroy</code></h4>

`HTTP.destroy` makes a DESTROY-request. <br><br>

**Arguments:**

url : String - Destination of the request
headers : Object - Header List

**Returns:**

response : Response

<h4 class="subtitle is-4">Function <code>head</code></h4>

`HTTP.head` makes a HEAD-request. <br><br>

**Arguments:**

url : String - Destination of the request
headers : Object - Header List

**Returns:**

response : Response

<h3 class="subtitle is-3 content">Module Console</h3>
<h4 class="subtitle is-4">Function <code>log</code></h4>

`console.log` writes a string to the console. <br><br>

**Arguments:**

args : Any[] - Accepts an array of arguments of any type and logs each argument to the console

**Returns:**

Nothing returned

<h4 class="subtitle is-4">Function <code>warning</code></h4>

`console.warning` writes a warning-string to the console. <br><br>

**Arguments:**

args : Any[] - Accepts an array of arguments of any type and logs each argument to the console

**Returns:**

Nothing returned
<h4 class="subtitle is-4">Function <code>error</code></h4>

`console.error` writes a error-string to the console. <br><br>

**Arguments:**

args : Any[] - Accepts an array of arguments of any type and logs each argument to the console

**Returns:**

Nothing returned

<h3 class="subtitle is-3 content">Global Helper</h3>
<h4 class="subtitle is-4">Function <code>UrlEncoded</code></h4>

Url encodes multiple key-value pairs.

**Arguments:**

entries : Object - A flat object of key-value pairs.

**Returns:**

encoded : UrlEncoded

<h4 class="subtitle is-4">Function <code>FormData</code></h4>

Transforms multiple key-value pairs to a FormData object.

**Arguments:**

entries : Object - A flat object of key-value pairs.

**Returns:**

formData : FormData