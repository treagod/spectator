<template>
  <div>
    <div class="has-text-centered">
      <h1 class="title is-1">Documentation</h1>
      <h2 class="subtitle is-5">
        Learn how to use Spectator and access APIs with Spectator. Theses pages
        cover the most used functionalties. If you still have any questions
        don't

        <a
          target="_blank"
          rel="noopener noreferrer"
          href="https://github.com/treagod/spectator/issues"
          >hesitate and ask!</a
        >
      </h2>
    </div>
    <div id="search-input">
      <div class="field has-addons">
        <div class="control is-expanded">
          <input
            v-model="searchQuery"
            autocomplete="off"
            class="input"
            type="text"
            placeholder="Search in topics…"
          />
        </div>
        <div class="control">
          <a class="button is-spectator"> Search</a>
        </div>
      </div>
    </div>
    <div v-if="results.length">
      <h2 class="title is-2">
        Found {{results.length}} possible matching {{results.length == 1 ? 'result' : 'results'}}
      </h2>
      <div class="columns is-multiline">
        <div
          class="column is-one-third"
          v-for="result in results"
          :key="result.title"
        >
          <div class="column">
              <NuxtLink :to="convertToUrl(result.slug)">
                <div class="card">
                  <div class="card-content">
                    <div class="content">
                      <h3 class="title is-3">{{ result.title}}</h3>
                      <p>
                        {{result.description}}
                      </p>
                    </div>
                  </div>
                </div>
              </NuxtLink>
            </div>
        </div>
      </div>
    </div>
    <div v-else>
      <div id="topics" class="rows">
        <div class="row">
          <div class="columns">
            <div class="column">
              <div class="card">
                <div class="card-content">
                  <div class="content">
                    <h3 class="title is-3">Getting Started</h3>
                    <p>
                      Get familiar with the UI and build your first requests
                      with Spectator.
                    </p>
                    <ul>
                      <li>
                        <NuxtLink to="/docs/getting-started/installation">
                          Installation
                        </NuxtLink>
                      </li>
                      <li>
                        <NuxtLink to="/docs/getting-started">
                          Sending your first request
                        </NuxtLink>
                      </li>
                      <li>
                        <NuxtLink to="/docs/getting-started/collections">
                          Categorize your requests in collections
                        </NuxtLink>
                      </li>
                      <li>
                        <NuxtLink to="/docs/getting-started/configure_body">
                          Configure the request body
                        </NuxtLink>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
            <div class="column">
              <div class="card">
                <div class="card-content">
                  <div class="content">
                    <h3 class="title is-3">Scripting</h3>
                    <p>
                      Learn how to use the scripting engine to dynmaically
                      extend your requests.
                    </p>
                    <ul>
                      <li>
                        <NuxtLink to="/docs/scripting">
                          Introduction
                        </NuxtLink>
                      </li>
                      <li>
                        <NuxtLink to="/docs/scripting/build_in">
                          Build-Ins
                        </NuxtLink>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
            <div class="column">
              <div class="card">
                <div class="card-content">
                  <div class="content">
                    <h3 class="title is-3">Environments</h3>
                    <p>
                      Learn how to use the scripting engine to dynmaically
                      extend your requests.
                    </p>
                    <ul>
                      <li>
                        <NuxtLink to="/docs/environment">
                          Create an environment
                        </NuxtLink>
                      </li>
                      <li>
                        <NuxtLink to="/docs/environment/variables">
                          Create and use variables
                        </NuxtLink>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  data() {
    return {
      searchQuery: "",
      results: [],
    };
  },
  methods: {
    convertToUrl(slug : string) {
      if (slug == 'installation') {
        return 'docs/getting-started/installation';
      } else if ('getting-started') {
        return 'docs/getting-started'
      }

      return '#'
    }
  },
  head() {
    return {
      title: "Spectator - Documentation",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Manual how to use Spectator",
        },
      ],
    };
  },
  watch: {
    async searchQuery(searchQuery) {
      if (!searchQuery) {
        this.results = [];
        return;
      }
      let scripting = await this.$content("scripting")
        .search(searchQuery)
        .fetch();
      let gettingStarted = await this.$content("getting-started")
        .search(searchQuery)
        .fetch();
      let environment = await this.$content("environment")
        .search(searchQuery)
        .fetch();

      this.results = scripting.concat(gettingStarted).concat(environment);

    },
  },
});
</script>

<style scoped>
.title.is-1 {
  margin-bottom: 1em;
}

#topics {
  margin-top: 2rem;
}

.card {
  padding-left: 1.25rem;
}

.title.is-3 {
  font-weight: normal;
}

.column .card {
  height: 100%;
}

.card a {
  color: #668e2c;
}

.card a:hover {
  color: #4a4a4a;
}

#search-input {
  margin: 2.5rem;
}

@media screen and (min-width: 800px) {
  #search-input .field.has-addons {
    width: 50%;
    margin-left: 25%;
  }

  .subtitle.is-5 {
    margin: -1.25rem 8rem 0;
  }
}
@media screen and (max-width: 390px) {
  .title.is-1 {
    font-size: 2.5rem;
  }
}

#search-input input:focus {
  border-color: #668e2c;
  box-shadow: 0 0 0 0.125em #b7c2a7;
}

.is-spectator {
  background-color: #668e2c;
  color: white;
}
</style>
