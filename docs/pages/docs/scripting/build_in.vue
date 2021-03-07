<template>
  <getting-started-base category-name="Scripting" page-name="Scripting Build-Ins">
    <div class="has-text-centered">
      <h1 class="title is-1">Scripting Build-Ins</h1>
    </div>

    <nuxt-content id="doc-content" :document="build_ins" />
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
      title: "Spectator - Scripting Build-Ins",
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Overview of Spectator scripting build-ins",
        },
      ],
    };
  },
  async asyncData({ $content, params }) {
    const build_ins = await $content(
      "scripting/build_ins"
    ).fetch();

    return { build_ins };
  },
});
</script>

<style>
#doc-content .subtitle {
  margin-top: 0.75em;
}
</style>
