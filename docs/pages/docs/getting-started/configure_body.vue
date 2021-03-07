<template>
  <getting-started-base category-name="Getting Started" page-name="Configure the request body">
    <div class="has-text-centered">
      <h1 class="title is-1">Configure the request body</h1>
    </div>

    <nuxt-content id="doc-content" :document="configure_body" />
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
      title: "Spectator - Configure Request Body",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Configure the request body of your REST request with Spectator",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const configure_body = await $content(
      "getting-started/configure_body"
    ).fetch();

    return { configure_body };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
