---
title:  Create and use environment variables inside Spectator
description: Create variables for your environment in Spectator to make your requests more dynamic
---

<h2 class="subtitle is-2 content">Create a variable</h2>

Click on environment in the menu in the top right corner to access the environment dialog.

<img class="guide-image" src="/envs/open_env_dialog.png">

A dialog will open where already a default environment is created. This environment will automatically be created
when no other environment exists. Let's create a new variable by clicking on **Add variable**.

<img class="guide-image shadow" src="/envs/add_variable.png">

Let's call the variable `id` and give it a value of `5`.

<img class="guide-image" src="/envs/after_variable_create.png">

Close the environment window. Make sure you have the correct environment selected to access your variable.

Focus the input entry of the URL of your request and press `Ctrl + Space`. A dropdown will appear where all your defined
variables are listed. Select the variable `id`.

<img class="guide-image" src="/envs/variable_dropdown.png">

You will see a mint colored `id` inside your URL. If you check your request list, the variable will correctly be resolved to a 5

<img class="guide-image" src="/envs/resolve.png">