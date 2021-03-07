<template>
  <div>
    <div class="has-text-centered">
      <h1 class="title is-1">News</h1>
    </div>
    <div id="articles">
      <div class="card">
        <div class="card-content">
          <div class="content">
            <div class="news-header">
              <h3 class="title is-3">Version 0.8 released!</h3>
              <p><span class="date">Posted on 16.01.2021</span> <span class="author">Marvin</span></p>
              <hr />
            </div>

            <p>
              Lorem ipsum dolor sit amet, consetetur sadipscing elitr,
              sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
              At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
              sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
              eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo
              duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            </p>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-content">
          <div class="content">
            <div class="news-header">
              <h3 class="title is-3">Version 0.8 released!</h3>
              <p><span class="date">Posted on 16.01.2021</span> <span class="author">Marvin</span></p>
              <hr />
            </div>

            <p>
              Lorem ipsum dolor sit amet, consetetur sadipscing elitr,
              sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
              At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
              sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
              eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo
              duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            </p>
          </div>
        </div>
      </div>
      <div class="card">
        <div class="card-content">
          <div class="content">
            <div class="news-header">
              <h3 class="title is-3">Version 0.8 released!</h3>
              <p><span class="date">Posted on 16.01.2021</span> <span class="author">Marvin</span></p>
              <hr />
            </div>

            <p>
              Lorem ipsum dolor sit amet, consetetur sadipscing elitr,
              sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
              At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata
              sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
              eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo
              duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  head() {
    return {
      title: "Spectator - Documentation",
    };
  },
});
</script>

<style scoped>
.title.is-1 {
  margin-bottom: 1em;
}

.news-header h3.title {
    margin-bottom: 0.15rem;
}

.news-header .author {
    color: #a5a5a5;
}

.news-header p {
    font-style: italic;
}

.news-header hr {
    margin-top: 0.1rem;
    margin-bottom: 0.95rem;
}

#topics {
  margin-top: 2rem;
}

#articles .card {
    margin-bottom: 1.5rem;
}

.card {
  padding: 0 0.75rem;
}

.card a {
  color: #668e2c;
}

.card a:hover {
  color: #4a4a4a;
}

.is-spectator {
  background-color: #668e2c;
  color: white;
}
</style>
