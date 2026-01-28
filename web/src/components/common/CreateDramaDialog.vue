<template>
  <!-- Create Drama Dialog / 创建短剧弹窗 -->
  <el-dialog
    v-model="visible"
    :title="$t('drama.createNew')"
    width="620px"
    :close-on-click-modal="false"
    class="create-dialog"
    @closed="handleClosed"
  >
    <div class="dialog-desc">{{ $t('drama.createDesc') }}</div>
    
    <el-form 
      ref="formRef" 
      :model="form" 
      :rules="rules" 
      label-position="top"
      class="create-form"
      @submit.prevent="handleSubmit"
    >
      <el-form-item :label="$t('drama.projectName')" prop="title" required>
        <el-input 
          v-model="form.title" 
          :placeholder="$t('drama.projectNamePlaceholder')"
          size="large"
          maxlength="100"
          show-word-limit
        />
      </el-form-item>

      <el-form-item :label="$t('drama.projectDesc')" prop="description">
        <el-input 
          v-model="form.description" 
          type="textarea" 
          :rows="3"
          :placeholder="$t('drama.projectDescPlaceholder')"
          maxlength="500"
          show-word-limit
          resize="none"
        />
      </el-form-item>

      <!-- 风格配置区域 -->
      <el-divider content-position="left">
        <span class="divider-text">🎨 风格配置（可选）</span>
      </el-divider>

      <div class="style-grid">
        <el-form-item label="画面风格">
          <el-select
            v-model="styleConfig.visualStyle"
            placeholder="请选择"
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="item in visualStyleOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="叙事风格">
          <el-select
            v-model="styleConfig.narrativeStyle"
            placeholder="请选择"
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="item in narrativeStyleOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="色调风格">
          <el-select
            v-model="styleConfig.colorTone"
            placeholder="请选择"
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="item in colorToneOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="时代背景">
          <el-select
            v-model="styleConfig.era"
            placeholder="请选择"
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="item in eraOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
      </div>

      <el-form-item label="自定义风格">
        <el-input
          v-model="styleConfig.customStyle"
          type="textarea"
          :rows="2"
          placeholder="补充其他风格要求，如：赛博朋克、水彩画风..."
          maxlength="200"
          show-word-limit
          resize="none"
        />
      </el-form-item>

      <!-- 风格预览 -->
      <div v-if="hasStyleSelected" class="style-preview">
        <el-tag v-if="styleConfig.visualStyle" type="primary" size="small">
          {{ getStyleLabel('visual', styleConfig.visualStyle) }}
        </el-tag>
        <el-tag v-if="styleConfig.narrativeStyle" type="success" size="small">
          {{ getStyleLabel('narrative', styleConfig.narrativeStyle) }}
        </el-tag>
        <el-tag v-if="styleConfig.colorTone" type="warning" size="small">
          {{ getStyleLabel('color', styleConfig.colorTone) }}
        </el-tag>
        <el-tag v-if="styleConfig.era" type="info" size="small">
          {{ getStyleLabel('era', styleConfig.era) }}
        </el-tag>
        <el-tag v-if="styleConfig.customStyle" type="danger" size="small">
          {{ styleConfig.customStyle.length > 10 ? styleConfig.customStyle.substring(0, 10) + '...' : styleConfig.customStyle }}
        </el-tag>
      </div>
    </el-form>

    <template #footer>
      <div class="dialog-footer">
        <el-button size="large" @click="handleClose">
          {{ $t('common.cancel') }}
        </el-button>
        <el-button 
          type="primary" 
          size="large"
          :loading="loading"
          @click="handleSubmit"
        >
          <el-icon v-if="!loading"><Plus /></el-icon>
          {{ $t('drama.createNew') }}
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { dramaAPI } from '@/api/drama'
import type { CreateDramaRequest } from '@/types/drama'

/**
 * CreateDramaDialog - Reusable dialog for creating new drama projects
 * 创建短剧弹窗 - 可复用的创建短剧项目弹窗
 */
const props = defineProps<{
  modelValue: boolean
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'created': [id: string]
}>()

const router = useRouter()
const formRef = ref<FormInstance>()
const loading = ref(false)

// v-model binding / 双向绑定
const visible = ref(props.modelValue)
watch(() => props.modelValue, (val) => {
  visible.value = val
})
watch(visible, (val) => {
  emit('update:modelValue', val)
})

// Form data / 表单数据
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
  { value: 'realistic', label: '写实风格' },
  { value: 'anime', label: '动漫风格' },
  { value: 'cartoon', label: '卡通风格' },
  { value: 'oil-painting', label: '油画风格' },
  { value: 'watercolor', label: '水彩风格' },
  { value: 'ink-wash', label: '水墨风格' },
  { value: 'pixel-art', label: '像素风格' },
  { value: 'cyberpunk', label: '赛博朋克' },
  { value: '3d-render', label: '3D渲染' },
  { value: 'minimalist', label: '极简风格' }
]

// 叙事风格选项
const narrativeStyleOptions = [
  { value: 'comedy', label: '轻松幽默' },
  { value: 'thriller', label: '紧张刺激' },
  { value: 'romantic', label: '浪漫温馨' },
  { value: 'dramatic', label: '戏剧张力' },
  { value: 'documentary', label: '纪实风格' },
  { value: 'epic', label: '史诗宏大' },
  { value: 'noir', label: '黑色电影' },
  { value: 'slice-of-life', label: '日常生活' }
]

// 色调风格选项
const colorToneOptions = [
  { value: 'warm', label: '暖色调' },
  { value: 'cool', label: '冷色调' },
  { value: 'vibrant', label: '鲜艳明亮' },
  { value: 'muted', label: '柔和淡雅' },
  { value: 'monochrome', label: '黑白单色' },
  { value: 'sepia', label: '复古棕褐' },
  { value: 'neon', label: '霓虹闪烁' },
  { value: 'pastel', label: '马卡龙色' }
]

// 时代背景选项
const eraOptions = [
  { value: 'ancient-china', label: '中国古代' },
  { value: 'ancient-europe', label: '欧洲古代' },
  { value: 'modern', label: '现代都市' },
  { value: 'republican', label: '民国时期' },
  { value: 'future', label: '未来科幻' },
  { value: 'post-apocalyptic', label: '末日废土' },
  { value: 'fantasy', label: '奇幻世界' },
  { value: 'steampunk', label: '蒸汽朋克' }
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

// Validation rules / 验证规则
const rules: FormRules = {
  title: [
    { required: true, message: '请输入项目标题', trigger: 'blur' },
    { min: 1, max: 100, message: '标题长度在 1 到 100 个字符', trigger: 'blur' }
  ]
}

// Reset form when dialog closes / 关闭时重置表单
const handleClosed = () => {
  form.title = ''
  form.description = ''
  form.style = ''
  styleConfig.visualStyle = ''
  styleConfig.narrativeStyle = ''
  styleConfig.colorTone = ''
  styleConfig.era = ''
  styleConfig.customStyle = ''
  formRef.value?.resetFields()
}

// Close dialog / 关闭弹窗
const handleClose = () => {
  visible.value = false
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
        visible.value = false
        emit('created', drama.id)
        // Navigate to drama detail page / 跳转到短剧详情页
        router.push(`/dramas/${drama.id}`)
      } catch (error: any) {
        ElMessage.error(error.message || '创建失败')
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped>
/* ========================================
   Dialog Styles / 弹窗样式
   ======================================== */
.create-dialog :deep(.el-dialog) {
  border-radius: var(--radius-xl);
}

.create-dialog :deep(.el-dialog__header) {
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid var(--border-primary);
  margin-right: 0;
}

.create-dialog :deep(.el-dialog__title) {
  font-size: 1.125rem;
  font-weight: 600;
  color: var(--text-primary);
}

.create-dialog :deep(.el-dialog__body) {
  padding: 1.5rem;
  max-height: 70vh;
  overflow-y: auto;
}

.dialog-desc {
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
  color: var(--text-secondary);
}

/* ========================================
   Form Styles / 表单样式
   ======================================== */
.create-form :deep(.el-form-item) {
  margin-bottom: 1rem;
}

.create-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: var(--text-primary);
  margin-bottom: 0.5rem;
}

.create-form :deep(.el-input__wrapper),
.create-form :deep(.el-textarea__inner) {
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  box-shadow: 0 0 0 1px var(--border-primary) inset;
  transition: all var(--transition-fast);
}

.create-form :deep(.el-input__wrapper:hover),
.create-form :deep(.el-textarea__inner:hover) {
  box-shadow: 0 0 0 1px var(--border-secondary) inset;
}

.create-form :deep(.el-input__wrapper.is-focus),
.create-form :deep(.el-textarea__inner:focus) {
  box-shadow: 0 0 0 2px var(--accent) inset;
}

.create-form :deep(.el-input__inner),
.create-form :deep(.el-textarea__inner) {
  color: var(--text-primary);
}

.create-form :deep(.el-input__inner::placeholder),
.create-form :deep(.el-textarea__inner::placeholder) {
  color: var(--text-muted);
}

.create-form :deep(.el-input__count) {
  color: var(--text-muted);
  background: transparent;
}

/* ========================================
   Style Config / 风格配置区域
   ======================================== */
.divider-text {
  font-size: 13px;
  font-weight: 500;
  color: var(--text-primary);
}

.style-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0 1rem;
}

@media (max-width: 540px) {
  .style-grid {
    grid-template-columns: 1fr;
  }
}

.style-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 12px;
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  margin-bottom: 1rem;
}

/* ========================================
   Footer Styles / 底部样式
   ======================================== */
.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
}

.dialog-footer .el-button {
  min-width: 100px;
}
</style>
