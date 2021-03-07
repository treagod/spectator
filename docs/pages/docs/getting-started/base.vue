<template>
  <div>
    <nav class="breadcrumb" aria-label="breadcrumbs">
      <ul>
        <li><a href="/docs">Documentation</a></li>
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
    pageName: String
  }
});
</script>

<style scoped>
.breadcrumb a {
  color: #668e2c;
}
</style>