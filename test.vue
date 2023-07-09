<!--
Say Hello World with Vue!
-->

<script setup>
import { ref } from 'vue'

// A "ref" is a reactive data source that stores a value.
// Technically, we don't need to wrap the string with ref()
// in order to display it, but we will see in the next
// example why it is needed if we ever intend to change
// the value.
const message = ref('Hello World!')
</script>

<script>
var abc = "abc"
</script>

<script setup lang="ts">
let abc: string = "abc"
</script>

<template>
  <h1>{{ message }}</h1>
</template>

<style>
h1 {
  font-size: 100px;
}
</style>

<style lang="scss">
h1 {
  span {
    color: dodgerblue;
  }
}
</style>
