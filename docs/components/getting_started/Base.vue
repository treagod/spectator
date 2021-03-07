<template>
  <div>
    <nav class="breadcrumb" aria-label="breadcrumbs">
      <ul>
        <li><a href="docs">Documentation</a></li>
        <li class="is-active"><a href="#">Getting Started</a></li>
        <li class="is-active">
          <a href="#" aria-current="page">{{ pageName }}</a>
        </li>
      </ul>
    </nav>
    <slot></slot>
  </div>
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  props: {
    pageName: String,
  },
});
</script>

<style scoped>
.breadcrumb a {
  color: #668e2c;
}
</style>

<style>
.guide-image {
  max-height: 600px;
  margin-top: 0.5rem;
}

h2.content {
  margin-top: 0.45em !important;
}

.guide-image.shadow {
}

@media screen and (min-width: 800px) {
    .guide-image.shadow {
      filter: drop-shadow(2px 5px 10px #0000006b);
      margin-top: 0.75em;
      margin-bottom: 0.75em;
      margin-left: 1.45em;
    }
}
</style>