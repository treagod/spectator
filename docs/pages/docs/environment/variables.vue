<template>
  <getting-started-base category-name="Environment" page-name="Create and use variables">
    <div class="has-text-centered">
      <h1 class="title is-1">Create and use variables</h1>
    </div>

    <nuxt-content id="doc-content" :document="variables" />
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
      title: "Spectator - Create and use variables",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Create variables for your environment in Spectator to make your requests more dynamic",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const variables = await $content(
      "environment/variables"
    ).fetch();

    return { variables };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
