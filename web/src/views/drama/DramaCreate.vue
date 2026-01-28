<template>
  <!-- Drama Create Page / 创建短剧页面 -->
  <div class="page-container">
    <DevLabel name="DramaCreate.vue" color="#27ae60" />
    <div class="content-wrapper animate-fade-in">
      <!-- Header / 头部 -->
      <AppHeader :fixed="false" :show-logo="false">
        <template #left>
          <el-button text @click="goBack" class="back-btn">
            <el-icon><ArrowLeft /></el-icon>
            <span>返回</span>
          </el-button>
          <div class="page-title">
            <h1>创建新项目</h1>
            <span class="subtitle">填写基本信息来创建你的短剧项目</span>
          </div>
        </template>
      </AppHeader>

      <!-- Form Card / 表单卡片 -->
      <div class="form-card">

        <el-form 
          ref="formRef" 
          :model="form" 
          :rules="rules" 
          label-position="top"
          class="create-form"
          @submit.prevent="handleSubmit"
        >
          <el-form-item label="项目标题" prop="title" required>
            <el-input 
              v-model="form.title" 
              placeholder="给你的短剧起个名字"
              size="large"
              maxlength="100"
              show-word-limit
            />
          </el-form-item>

          <el-form-item label="项目描述" prop="description">
            <el-input 
              v-model="form.description" 
              type="textarea" 
              :rows="3"
              placeholder="简要描述你的短剧内容、风格或创意（可选）"
              maxlength="500"
              show-word-limit
              resize="none"
            />
          </el-form-item>

          <!-- 风格配置区域 -->
          <el-divider content-position="left">
            <span class="divider-text">🎨 风格配置</span>
          </el-divider>

          <div class="style-grid">
            <el-form-item label="画面风格">
              <el-select
                v-model="styleConfig.visualStyle"
                placeholder="请选择画面风格"
                clearable
                style="width: 100%"
              >
                <el-option
                  v-for="item in visualStyleOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                >
                  <div class="option-with-desc">
                    <span>{{ item.label }}</span>
                    <span class="option-desc">{{ item.description }}</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>

            <el-form-item label="叙事风格">
              <el-select
                v-model="styleConfig.narrativeStyle"
                placeholder="请选择叙事风格"
                clearable
                style="width: 100%"
              >
                <el-option
                  v-for="item in narrativeStyleOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                >
                  <div class="option-with-desc">
                    <span>{{ item.label }}</span>
                    <span class="option-desc">{{ item.description }}</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>

            <el-form-item label="色调风格">
              <el-select
                v-model="styleConfig.colorTone"
                placeholder="请选择色调风格"
                clearable
                style="width: 100%"
              >
                <el-option
                  v-for="item in colorToneOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                >
                  <div class="option-with-desc">
                    <span>{{ item.label }}</span>
                    <span class="option-desc">{{ item.description }}</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>

            <el-form-item label="时代背景">
              <el-select
                v-model="styleConfig.era"
                placeholder="请选择时代背景"
                clearable
                style="width: 100%"
              >
                <el-option
                  v-for="item in eraOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                >
                  <div class="option-with-desc">
                    <span>{{ item.label }}</span>
                    <span class="option-desc">{{ item.description }}</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>
          </div>

          <el-form-item label="自定义风格补充">
            <el-input
              v-model="styleConfig.customStyle"
              type="textarea"
              :rows="2"
              placeholder="补充其他风格要求，如：赛博朋克、水彩画风、暗黑哥特..."
              maxlength="200"
              show-word-limit
              resize="none"
            />
          </el-form-item>

          <!-- 风格预览 -->
          <div v-if="hasStyleSelected" class="style-preview">
            <div class="preview-label">当前风格配置：</div>
            <div class="preview-tags">
              <el-tag v-if="styleConfig.visualStyle" type="primary">
                {{ getStyleLabel('visual', styleConfig.visualStyle) }}
              </el-tag>
              <el-tag v-if="styleConfig.narrativeStyle" type="success">
                {{ getStyleLabel('narrative', styleConfig.narrativeStyle) }}
              </el-tag>
              <el-tag v-if="styleConfig.colorTone" type="warning">
                {{ getStyleLabel('color', styleConfig.colorTone) }}
              </el-tag>
              <el-tag v-if="styleConfig.era" type="info">
                {{ getStyleLabel('era', styleConfig.era) }}
              </el-tag>
              <el-tag v-if="styleConfig.customStyle" type="danger">
                {{ styleConfig.customStyle.length > 15 ? styleConfig.customStyle.substring(0, 15) + '...' : styleConfig.customStyle }}
              </el-tag>
            </div>
          </div>

          <div class="form-actions">
            <el-button size="large" @click="goBack">取消</el-button>
            <el-button 
              type="primary" 
              size="large"
              :loading="loading"
              @click="handleSubmit"
            >
              <el-icon v-if="!loading"><Plus /></el-icon>
              创建项目
            </el-button>
          </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { ArrowLeft, Plus } from '@element-plus/icons-vue'
import { dramaAPI } from '@/api/drama'
import type { CreateDramaRequest } from '@/types/drama'
import { AppHeader } from '@/components/common'

const router = useRouter()
const formRef = ref<FormInstance>()
const loading = ref(false)

const form = reactive<CreateDramaRequest>({
  title: '',
  description: '',
  style: ''
})

// 风格配置
const styleConfig = reactive({
  visualStyle: '',
  narrativeStyle: '',
  colorTone: '',
  era: '',
  customStyle: ''
})

// 画面风格选项
const visualStyleOptions = [
  { value: 'realistic', label: '写实风格', description: '真实感强的画面' },
  { value: 'anime', label: '动漫风格', description: '日式动漫画风' },
  { value: 'cartoon', label: '卡通风格', description: '欧美卡通画风' },
  { value: 'oil-painting', label: '油画风格', description: '古典油画质感' },
  { value: 'watercolor', label: '水彩风格', description: '清新水彩画风' },
  { value: 'ink-wash', label: '水墨风格', description: '中国水墨画风' },
  { value: 'pixel-art', label: '像素风格', description: '复古像素游戏' },
  { value: 'cyberpunk', label: '赛博朋克', description: '科幻霓虹效果' },
  { value: '3d-render', label: '3D渲染', description: '三维渲染效果' },
  { value: 'minimalist', label: '极简风格', description: '简洁干净画面' }
]

// 叙事风格选项
const narrativeStyleOptions = [
  { value: 'comedy', label: '轻松幽默', description: '搞笑欢乐' },
  { value: 'thriller', label: '紧张刺激', description: '悬疑惊悚' },
  { value: 'romantic', label: '浪漫温馨', description: '甜蜜治愈' },
  { value: 'dramatic', label: '戏剧张力', description: '冲突反转' },
  { value: 'documentary', label: '纪实风格', description: '真实客观' },
  { value: 'epic', label: '史诗宏大', description: '气势磅礴' },
  { value: 'noir', label: '黑色电影', description: '阴郁神秘' },
  { value: 'slice-of-life', label: '日常生活', description: '平淡温馨' }
]

// 色调风格选项
const colorToneOptions = [
  { value: 'warm', label: '暖色调', description: '温暖舒适' },
  { value: 'cool', label: '冷色调', description: '清冷理性' },
  { value: 'vibrant', label: '鲜艳明亮', description: '高饱和度' },
  { value: 'muted', label: '柔和淡雅', description: '低饱和度' },
  { value: 'monochrome', label: '黑白单色', description: '经典黑白' },
  { value: 'sepia', label: '复古棕褐', description: '怀旧效果' },
  { value: 'neon', label: '霓虹闪烁', description: '荧光霓虹' },
  { value: 'pastel', label: '马卡龙色', description: '柔和糖果' }
]

// 时代背景选项
const eraOptions = [
  { value: 'ancient-china', label: '中国古代', description: '汉唐宋明清' },
  { value: 'ancient-europe', label: '欧洲古代', description: '中世纪文艺复兴' },
  { value: 'modern', label: '现代都市', description: '当代城市' },
  { value: 'republican', label: '民国时期', description: '20世纪初' },
  { value: 'future', label: '未来科幻', description: '科技未来' },
  { value: 'post-apocalyptic', label: '末日废土', description: '文明崩溃' },
  { value: 'fantasy', label: '奇幻世界', description: '魔法冒险' },
  { value: 'steampunk', label: '蒸汽朋克', description: '蒸汽机械' }
]

// 是否选择了风格
const hasStyleSelected = computed(() => {
  return styleConfig.visualStyle ||
    styleConfig.narrativeStyle ||
    styleConfig.colorTone ||
    styleConfig.era ||
    styleConfig.customStyle
})

// 获取风格标签名称
const getStyleLabel = (type: string, value: string) => {
  const optionsMap: Record<string, any[]> = {
    visual: visualStyleOptions,
    narrative: narrativeStyleOptions,
    color: colorToneOptions,
    era: eraOptions
  }
  const options = optionsMap[type] || []
  const option = options.find(o => o.value === value)
  return option?.label || value
}

// 生成风格字符串
const generateStyleString = () => {
  const parts: string[] = []

  if (styleConfig.visualStyle) {
    const opt = visualStyleOptions.find(o => o.value === styleConfig.visualStyle)
    if (opt) parts.push(opt.label)
  }
  if (styleConfig.narrativeStyle) {
    const opt = narrativeStyleOptions.find(o => o.value === styleConfig.narrativeStyle)
    if (opt) parts.push(opt.label)
  }
  if (styleConfig.colorTone) {
    const opt = colorToneOptions.find(o => o.value === styleConfig.colorTone)
    if (opt) parts.push(opt.label)
  }
  if (styleConfig.era) {
    const opt = eraOptions.find(o => o.value === styleConfig.era)
    if (opt) parts.push(opt.label)
  }
  if (styleConfig.customStyle) {
    parts.push(styleConfig.customStyle)
  }

  return parts.join('，')
}

const rules: FormRules = {
  title: [
    { required: true, message: '请输入项目标题', trigger: 'blur' },
    { min: 1, max: 100, message: '标题长度在 1 到 100 个字符', trigger: 'blur' }
  ]
}

// Submit form / 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        // 生成风格字符串
        form.style = generateStyleString()

        const drama = await dramaAPI.create(form)
        ElMessage.success('创建成功')
        router.push(`/dramas/${drama.id}`)
      } catch (error: any) {
        ElMessage.error(error.message || '创建失败')
      } finally {
        loading.value = false
      }
    }
  })
}

// Go back / 返回上一页
const goBack = () => {
  router.back()
}
</script>

<style scoped>
/* ========================================
   Page Layout / 页面布局 - 紧凑边距
   ======================================== */
.page-container {
  min-height: 100vh;
  background-color: var(--bg-primary);
  padding: var(--space-2) var(--space-3);
  transition: background-color var(--transition-normal);
}

@media (min-width: 768px) {
  .page-container {
    padding: var(--space-3) var(--space-4);
  }
}

.content-wrapper {
  max-width: 720px;
  margin: 0 auto;
}

/* ========================================
   Form Card / 表单卡片
   ======================================== */
.form-card {
  background: var(--bg-card);
  border: 1px solid var(--border-primary);
  border-radius: var(--radius-xl);
  overflow: hidden;
  box-shadow: var(--shadow-card);
}

/* ========================================
   Form Styles / 表单样式 - 紧凑内边距
   ======================================== */
.create-form {
  padding: var(--space-4);
}

.create-form :deep(.el-form-item) {
  margin-bottom: var(--space-3);
}

/* ========================================
   Style Config / 风格配置区域
   ======================================== */
.divider-text {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
}

.style-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0 var(--space-4);
}

@media (max-width: 640px) {
  .style-grid {
    grid-template-columns: 1fr;
  }
}

.option-with-desc {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.option-desc {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
}

:deep(.el-select-dropdown__item) {
  height: auto;
  line-height: 1.5;
  padding: 8px 12px;
}

/* ========================================
   Style Preview / 风格预览
   ======================================== */
.style-preview {
  background: var(--el-fill-color-light);
  border-radius: var(--radius-md);
  padding: var(--space-3);
  margin-bottom: var(--space-4);
}

.preview-label {
  font-size: 13px;
  color: var(--el-text-color-secondary);
  margin-bottom: var(--space-2);
}

.preview-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* ========================================
   Form Actions / 表单操作区
   ======================================== */
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
  padding-top: var(--space-4);
  border-top: 1px solid var(--border-primary);
  margin-top: var(--space-2);
}

.form-actions .el-button {
  min-width: 100px;
}
</style>
