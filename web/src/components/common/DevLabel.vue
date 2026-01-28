<template>
  <div v-if="isVisible" class="dev-label" :style="{ backgroundColor: color }">
    📁 {{ name }}
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  name: string
  color?: string
}>()

// 开发环境或通过 localStorage 开启时显示
// 在浏览器控制台输入: localStorage.setItem('showDevLabels', 'true') 然后刷新页面即可显示
// 关闭: localStorage.removeItem('showDevLabels')
const isVisible = computed(() => {
  return true
})

const color = computed(() => props.color || '#ff6b6b')
</script>

<style scoped>
.dev-label {
  position: fixed;
  top: 8px;
  right: 8px;
  z-index: 99999;
  padding: 6px 14px;
  font-size: 12px;
  font-weight: bold;
  color: white;
  border-radius: 4px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.4);
  pointer-events: none;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  letter-spacing: 0.5px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}
</style>
