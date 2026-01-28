<template>
  <div class="script-edit-container">
    <DevLabel name="ScriptEdit.vue" color="#7f8c8d" />
    <el-page-header @back="goBack" title="返回">
      <template #content>
        <h2>剧本编辑</h2>
      </template>
      <template #extra>
        <el-button type="primary" @click="saveSettings" :loading="saving">
          保存设置
        </el-button>
      </template>
    </el-page-header>

    <div class="settings-content">
      <!-- 风格配置区域 -->
      <el-card class="settings-card" shadow="never">
        <template #header>
          <div class="card-header">
            <span class="card-title">🎨 风格配置</span>
            <span class="card-subtitle">选择剧本的整体风格，影响AI生成的内容风格</span>
          </div>
        </template>

        <el-form :model="styleForm" label-width="100px" class="style-form">
          <el-form-item label="画面风格">
            <el-select
              v-model="styleForm.visualStyle"
              placeholder="请选择画面风格"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="item in visualStyleOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              >
                <div class="option-item">
                  <span class="option-label">{{ item.label }}</span>
                  <span class="option-desc">{{ item.description }}</span>
                </div>
              </el-option>
            </el-select>
            <div class="form-tip">决定生成图片和视频的整体视觉风格</div>
          </el-form-item>

          <el-form-item label="叙事风格">
            <el-select
              v-model="styleForm.narrativeStyle"
              placeholder="请选择叙事风格"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="item in narrativeStyleOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              >
                <div class="option-item">
                  <span class="option-label">{{ item.label }}</span>
                  <span class="option-desc">{{ item.description }}</span>
                </div>
              </el-option>
            </el-select>
            <div class="form-tip">影响剧情的叙事节奏和情感基调</div>
          </el-form-item>

          <el-form-item label="色调风格">
            <el-select
              v-model="styleForm.colorTone"
              placeholder="请选择色调风格"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="item in colorToneOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              >
                <div class="option-item">
                  <span class="option-label">{{ item.label }}</span>
                  <span class="option-desc">{{ item.description }}</span>
                </div>
              </el-option>
            </el-select>
            <div class="form-tip">画面的整体色彩倾向</div>
          </el-form-item>

          <el-form-item label="时代背景">
            <el-select
              v-model="styleForm.era"
              placeholder="请选择时代背景"
              style="width: 100%"
              clearable
            >
              <el-option
                v-for="item in eraOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              >
                <div class="option-item">
                  <span class="option-label">{{ item.label }}</span>
                  <span class="option-desc">{{ item.description }}</span>
                </div>
              </el-option>
            </el-select>
            <div class="form-tip">故事发生的时代设定</div>
          </el-form-item>

          <el-form-item label="自定义风格">
            <el-input
              v-model="styleForm.customStyle"
              type="textarea"
              :rows="3"
              placeholder="可以输入自定义的风格描述，例如：赛博朋克风格、水彩画风格、暗黑哥特风..."
            />
            <div class="form-tip">补充说明其他风格要求，会与上述选项组合使用</div>
          </el-form-item>
        </el-form>
      </el-card>

      <!-- 风格预览 -->
      <el-card class="preview-card" shadow="never" v-if="hasStyleSelected">
        <template #header>
          <div class="card-header">
            <span class="card-title">📋 当前风格配置预览</span>
          </div>
        </template>
        <div class="style-preview">
          <el-tag v-if="styleForm.visualStyle" type="primary" size="large">
            画面：{{ getStyleLabel('visual', styleForm.visualStyle) }}
          </el-tag>
          <el-tag v-if="styleForm.narrativeStyle" type="success" size="large">
            叙事：{{ getStyleLabel('narrative', styleForm.narrativeStyle) }}
          </el-tag>
          <el-tag v-if="styleForm.colorTone" type="warning" size="large">
            色调：{{ getStyleLabel('color', styleForm.colorTone) }}
          </el-tag>
          <el-tag v-if="styleForm.era" type="info" size="large">
            时代：{{ getStyleLabel('era', styleForm.era) }}
          </el-tag>
          <el-tag v-if="styleForm.customStyle" type="danger" size="large">
            自定义：{{ styleForm.customStyle.substring(0, 20) }}{{ styleForm.customStyle.length > 20 ? '...' : '' }}
          </el-tag>
        </div>
        <div class="style-prompt-preview" v-if="generatedStylePrompt">
          <div class="prompt-label">生成的风格提示词：</div>
          <div class="prompt-content">{{ generatedStylePrompt }}</div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { dramaAPI } from '@/api/drama'

const route = useRoute()
const router = useRouter()
const episodeId = route.params.id as string

const saving = ref(false)

// 风格表单
const styleForm = ref({
  visualStyle: '',
  narrativeStyle: '',
  colorTone: '',
  era: '',
  customStyle: ''
})

// 画面风格选项
const visualStyleOptions = [
  { value: 'realistic', label: '写实风格', description: '真实感强的画面效果' },
  { value: 'anime', label: '动漫风格', description: '日式动漫画风' },
  { value: 'cartoon', label: '卡通风格', description: '欧美卡通画风' },
  { value: 'oil-painting', label: '油画风格', description: '古典油画质感' },
  { value: 'watercolor', label: '水彩风格', description: '清新水彩画风' },
  { value: 'ink-wash', label: '水墨风格', description: '中国传统水墨画风' },
  { value: 'pixel-art', label: '像素风格', description: '复古像素游戏画风' },
  { value: 'cyberpunk', label: '赛博朋克', description: '科幻霓虹灯效果' },
  { value: '3d-render', label: '3D渲染', description: '三维渲染效果' },
  { value: 'minimalist', label: '极简风格', description: '简洁干净的画面' }
]

// 叙事风格选项
const narrativeStyleOptions = [
  { value: 'comedy', label: '轻松幽默', description: '搞笑、欢乐的氛围' },
  { value: 'thriller', label: '紧张刺激', description: '悬疑、惊悚的节奏' },
  { value: 'romantic', label: '浪漫温馨', description: '甜蜜、治愈的情感' },
  { value: 'dramatic', label: '戏剧张力', description: '强烈的冲突与反转' },
  { value: 'documentary', label: '纪实风格', description: '真实、客观的叙述' },
  { value: 'epic', label: '史诗宏大', description: '气势磅礴的叙事' },
  { value: 'noir', label: '黑色电影', description: '阴郁、神秘的氛围' },
  { value: 'slice-of-life', label: '日常生活', description: '平淡温馨的日常' }
]

// 色调风格选项
const colorToneOptions = [
  { value: 'warm', label: '暖色调', description: '温暖、舒适的色彩' },
  { value: 'cool', label: '冷色调', description: '清冷、理性的色彩' },
  { value: 'vibrant', label: '鲜艳明亮', description: '高饱和度色彩' },
  { value: 'muted', label: '柔和淡雅', description: '低饱和度色彩' },
  { value: 'monochrome', label: '黑白单色', description: '经典黑白效果' },
  { value: 'sepia', label: '复古棕褐', description: '怀旧老照片效果' },
  { value: 'neon', label: '霓虹闪烁', description: '荧光霓虹色彩' },
  { value: 'pastel', label: '马卡龙色', description: '柔和糖果色系' }
]

// 时代背景选项
const eraOptions = [
  { value: 'ancient-china', label: '中国古代', description: '汉唐宋明清等' },
  { value: 'ancient-europe', label: '欧洲古代', description: '中世纪、文艺复兴' },
  { value: 'modern', label: '现代都市', description: '当代城市生活' },
  { value: 'republican', label: '民国时期', description: '20世纪初中国' },
  { value: 'future', label: '未来科幻', description: '科技发达的未来' },
  { value: 'post-apocalyptic', label: '末日废土', description: '文明崩溃后的世界' },
  { value: 'fantasy', label: '奇幻世界', description: '魔法与冒险的世界' },
  { value: 'steampunk', label: '蒸汽朋克', description: '蒸汽机械时代' }
]

// 是否有选择风格
const hasStyleSelected = computed(() => {
  return styleForm.value.visualStyle ||
    styleForm.value.narrativeStyle ||
    styleForm.value.colorTone ||
    styleForm.value.era ||
    styleForm.value.customStyle
})

// 生成的风格提示词
const generatedStylePrompt = computed(() => {
  const parts: string[] = []

  if (styleForm.value.visualStyle) {
    const option = visualStyleOptions.find(o => o.value === styleForm.value.visualStyle)
    if (option) parts.push(option.label)
  }

  if (styleForm.value.narrativeStyle) {
    const option = narrativeStyleOptions.find(o => o.value === styleForm.value.narrativeStyle)
    if (option) parts.push(option.label)
  }

  if (styleForm.value.colorTone) {
    const option = colorToneOptions.find(o => o.value === styleForm.value.colorTone)
    if (option) parts.push(option.label)
  }

  if (styleForm.value.era) {
    const option = eraOptions.find(o => o.value === styleForm.value.era)
    if (option) parts.push(option.label)
  }

  if (styleForm.value.customStyle) {
    parts.push(styleForm.value.customStyle)
  }

  return parts.join('、')
})

// 获取风格标签名称
const getStyleLabel = (type: string, value: string) => {
  let options: any[] = []
  switch (type) {
    case 'visual':
      options = visualStyleOptions
      break
    case 'narrative':
      options = narrativeStyleOptions
      break
    case 'color':
      options = colorToneOptions
      break
    case 'era':
      options = eraOptions
      break
  }
  const option = options.find(o => o.value === value)
  return option?.label || value
}

// 加载已保存的风格设置
const loadStyleSettings = async () => {
  try {
    // 从localStorage加载保存的风格设置
    const savedStyle = localStorage.getItem(`drama_style_${episodeId}`)
    if (savedStyle) {
      const parsed = JSON.parse(savedStyle)
      styleForm.value = { ...styleForm.value, ...parsed }
    }
  } catch (error) {
    console.error('加载风格设置失败:', error)
  }
}

// 保存风格设置
const saveSettings = async () => {
  saving.value = true
  try {
    // 保存到localStorage
    localStorage.setItem(`drama_style_${episodeId}`, JSON.stringify(styleForm.value))
    ElMessage.success('风格设置已保存')
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败')
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  router.back()
}

onMounted(() => {
  loadStyleSettings()
})
</script>

<style scoped>
.script-edit-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.settings-content {
  margin-top: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.settings-card {
  border-radius: 12px;
}

.card-header {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.card-subtitle {
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.style-form {
  max-width: 600px;
}

.form-tip {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  margin-top: 4px;
}

.option-item {
  display: flex;
  flex-direction: column;
  padding: 4px 0;
}

.option-label {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.option-desc {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.preview-card {
  border-radius: 12px;
}

.style-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.style-prompt-preview {
  margin-top: 16px;
  padding: 12px;
  background: var(--el-fill-color-light);
  border-radius: 8px;
}

.prompt-label {
  font-size: 13px;
  color: var(--el-text-color-secondary);
  margin-bottom: 8px;
}

.prompt-content {
  font-size: 14px;
  color: var(--el-text-color-primary);
  line-height: 1.6;
}

:deep(.el-select-dropdown__item) {
  height: auto;
  line-height: 1.4;
  padding: 8px 12px;
}
</style>
