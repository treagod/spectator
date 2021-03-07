<template>
  <getting-started-base category-name="Environment" page-name="Create an Environment">
    <div class="has-text-centered">
      <h1 class="title is-1">Create an environment</h1>
    </div>

    <nuxt-content id="doc-content" :document="create_env" />
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
      title: "Spectator - Create an environment",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Create a environment in Spectator to make your REST requests more dynamic",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const create_env = await $content(
      "environment/create"
    ).fetch();

    return { create_env };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
