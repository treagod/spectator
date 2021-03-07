<template>
  <getting-started-base category-name="Getting Started" page-name="Create your first request">
    <div class="has-text-centered">
      <h1 class="title is-1">Create your first request</h1>
    </div>

    <nuxt-content id="doc-content" :document="create_request" />
  </getting-started-base>
</template>

<script lang="ts">
import Vue from "vue";
import Base from "@/components/Base.vue";

export default Vue.extend({
  components: {
    GettingStartedBase: Base,
  },
  head() {
    return {
      title: "Spectator - Getting Started",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Sending your first REST request with Spectator and inspect the response",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const create_request = await $content(
      "getting-started/create_request"
    ).fetch();

    return { create_request };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
