# Roadmap

## Rough Overview

* Allow Scripting ✔️
  * Error Reporting
  * Script Debug
  * Asynchronous HTTP requests
* Create Collections
  * Basic grouping of requests
  * Add collection variables
  * Defined execution of mulitple requests
  * Test-Enviroment for requests via JavaScript
* Authentication
  * Bearer-Token
  * OAuth
* Creating Workspaces

## Allow Scripting

Sometimes the request is more complex than adding headers and stuff. In order to give the developer more
flexibility in this regards, Spectator shall support execution of JavaScript Scripts before and after the
request is made. These scripts shall allow the developer to alter the request or do other HTTP requests first, e.g. 
for obtaining a JWT Token.

## Create Collections

The purpose of collecions is to enable the developer to group their requests.
Grouping could be something like all requests to a specific domain or requests which have some other relations 
(e.g. interacting APIs).

### Basic grouping of requests

The basics should cover a 1-n relationship between a collection and multiple requests

### Add collection variables

Variables should give the user the ability to save often used values like IDs.

### Defined execution of multiple requests

The user should be able to define an execution order of requests.
For example first login, create a blog post and then logout.

### Test-Enviroment for requests via JavaScript

To relieve the developer from repetitive testing of APIs, the user shall be able to 
automatic test their endpoints via JavaScript scripts.

## Authentication

As APIs are often secured by a authentication mechanism, Spectator shall offer a way of
easily authenticate to an API.

### Bearer-Token

The user shall be able to define a bearer-token which will be send with each request.

### OAuth

As a often used solution, Spectator shall support OAuth authentication.

## Creating Workspaces

Developers might work on multiple projects which they wish to seperate completly.
Therefore Spectator shall offer the possibility to create workspaces to
work in unique enviroments.
