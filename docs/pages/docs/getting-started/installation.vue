<template>
  <getting-started-base category-name="Getting Started" page-name="Installation">
    <div class="has-text-centered">
      <h1 class="title is-1">Installation</h1>
    </div>
    <nuxt-content id="doc-content" :document="installation" />
  </getting-started-base>
</template>

<script lang="ts">
import Vue from "vue";
import Base from "@/components/Base.vue"

export default Vue.extend({
  components: {
    GettingStartedBase: Base
  },
  head() {
    return {
      title: "Spectator - Installation",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Install Spectator from Elementary OS Appcenter, Flatpak or build it yourself from source",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const installation = await $content("getting-started/installation").fetch();

    return { installation };
  },
});
</script>