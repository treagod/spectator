<template>
  <div>
    <section class="hero">
      <div class="hero-body">
        <div class="container has-text-centered">
          <h1 id="hero-title" class="title">
            Testing APIs fast and efficiently
          </h1>
          <h2 class="subtitle">
            Spectator is a GTK based HTTP client that lets you define and send
            HTTP requests to test or consume an API . It has a beautiful native
            interface with main focus on
            <a href="https://elementary.io">Elementary OS</a>
            to compose requests and inspect the server responses.
          </h2>

          <img
            src="spectator.png"
            alt="Spectator Window"
            height="600"
            id="hero-img"
          />
        </div>
      </div>
    </section>
    <section class="section">
      <div class="container is-vcentered">
        <div class="has-text-centered">
          <h3 class="subtitle is-3">
            Fully customizable way to test your APIs
          </h3>
        </div>
        <div id="properties" class="columns has-text-centered">
          <div class="column">
            <div>
              <i data-feather="cloud"></i>
            </div>
            <h4 class="subtitle is-4">Access APIs</h4>
            <p>
              Build your requests with a beautiful native GTK+ interface and
              inspect the response. Define variables in different environments
              and use them according to your needs.
            </p>
          </div>
          <div class="column">
            <div>
              <i data-feather="activity"></i>
            </div>
            <h4 class="subtitle is-4">Dynamic</h4>
            <p>
              Spectator uses the Duktape JavaScript Engine to execute user
              defined scripts at runtime. Define your own pre- and
              post-behaviour before executing your actual request.
            </p>
          </div>
          <div class="column">
            <div>
              <i data-feather="cpu"></i>
            </div>
            <h4 class="subtitle is-4">Native</h4>
            <p>
              Spectator uses GTK+ to give you a native application. It is
              written in Vala and tries to use less memory as current
              alternatives.
            </p>
          </div>
        </div>
        <div id="call-to-action" class="has-text-centered">
            <NuxtLink class="button is-spectator" to="/docs">Get now started with Spectator!</NuxtLink>
        </div>
      </div>
    </section>
    <script>
      feather.replace();
    </script>
  </div>
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  layout: "landing",
  head() {
    return {
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Spectator is a GTK based tool developed for Elementary OS. Define requests, specify the headers, URL parameters and the body. Make your requests dynamic by using JavaScript to alter your requests.",
        },
      ],
    };
  },
});
</script>


<style scoped>
#call-to-action {
  margin-top: 1.75rem;
}

#call-to-action .is-spectator {
  background-color: #668e2c;
  color: white;
  padding: 1.75rem;
  font-size: 20px;
}

#hero-title {
  margin-top: 0.5em !important;
  margin-bottom: 1.85em !important;
}

#properties {
  margin-top: 1em;
}

@media screen and (min-width: 800px) {
  #hero-img {
    height: 600px;
  }
}
</style>