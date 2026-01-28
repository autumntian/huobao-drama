<template>
  <div class="character-extraction-container">
    <el-page-header @back="goBack" :title="$t('character.backToProject')">
      <template #content>
        <h2>{{ $t('character.title') }}</h2>
      </template>
    </el-page-header>

    <el-card shadow="never" class="main-card">
      <template #header>
        <div class="card-header">
          <h3>{{ $t('character.list') }}</h3>
          <div class="header-actions">
            <el-button @click="addCharacter">
              <el-icon><Plus /></el-icon>
              {{ $t('character.add') }}
            </el-button>
            <el-button type="primary" @click="saveCharacters" :loading="saving">
              {{ $t('character.saveChanges') }}
            </el-button>
          </div>
        </div>
      </template>

      <el-empty v-if="characters.length === 0" :description="$t('character.empty')" />

      <el-row :gutter="20" v-else>
        <el-col :span="8" v-for="character in characters" :key="character.id">
          <el-card shadow="hover" class="character-card">
            <template #header>
              <div class="character-header">
                <el-avatar :size="60">{{ character.name[0] }}</el-avatar>
                <div class="character-info">
                  <h4>{{ character.name }}</h4>
                  <el-tag size="small">{{ character.role }}</el-tag>
                </div>
              </div>
            </template>

            <div class="character-details">
              <p><strong>{{ $t('character.personality') }}：</strong>{{ character.personality }}</p>
              <p><strong>{{ $t('character.appearance') }}：</strong>{{ character.appearance }}</p>
              <p><strong>{{ $t('character.background') }}：</strong>{{ character.background }}</p>
            </div>

            <template #footer>
              <el-button-group style="width: 100%">
                <el-button size="small" @click="editCharacter(character)">{{ $t('common.edit') }}</el-button>
                <el-button size="small" type="primary" @click="generateCharacterImage(character)">
                  {{ $t('character.generateImage') }}
                </el-button>
              </el-button-group>
            </template>
          </el-card>
        </el-col>
      </el-row>

      <div class="actions" v-if="characters.length > 0">
        <el-button type="success" size="large" @click="goToNextStep">
          {{ $t('character.nextStep') }}
        </el-button>
      </div>
    </el-card>

    <!-- 编辑对话框 -->
    <el-dialog v-model="editDialogVisible" title="编辑角色" width="650px">
      <el-form :model="editForm" label-width="80px">
        <el-form-item label="姓名">
          <el-input v-model="editForm.name" />
        </el-form-item>
        <el-form-item label="角色">
          <el-input v-model="editForm.role" />
        </el-form-item>
        <el-form-item label="性格">
          <el-input v-model="editForm.personality" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="外貌">
          <el-input v-model="editForm.appearance" type="textarea" :rows="3" />
        </el-form-item>

        <!-- 图片风格配置 -->
        <el-divider content-position="left">
          <span class="divider-text">🎨 图片风格</span>
        </el-divider>

        <div class="style-grid">
          <el-form-item label="画面风格">
            <el-select
              v-model="editForm.visualStyle"
              placeholder="请选择"
              clearable
            >
              <el-option
                v-for="item in visualStyleOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="色调风格">
            <el-select
              v-model="editForm.colorTone"
              placeholder="请选择"
              clearable
            >
              <el-option
                v-for="item in colorToneOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </el-form-item>
        </div>

        <!-- 风格预览 -->
        <div v-if="hasStyleSelected" class="style-preview">
          <span class="preview-label">已选风格：</span>
          <el-tag v-if="editForm.visualStyle" type="primary" size="small">
            {{ getStyleLabel('visual', editForm.visualStyle) }}
          </el-tag>
          <el-tag v-if="editForm.colorTone" type="warning" size="small">
            {{ getStyleLabel('color', editForm.colorTone) }}
          </el-tag>
        </div>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveCharacter">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { MagicStick } from '@element-plus/icons-vue'
import { generationAPI } from '@/api/generation'
import type { Character } from '@/types/drama'

const route = useRoute()
const router = useRouter()
const dramaId = route.params.id as string

const characters = ref<Character[]>([])
const saving = ref(false)
const editDialogVisible = ref(false)
const editForm = reactive({
  name: '',
  role: '',
  personality: '',
  appearance: '',
  background: '',
  visualStyle: '',
  colorTone: ''
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

// 是否选择了风格
const hasStyleSelected = computed(() => {
  return editForm.visualStyle || editForm.colorTone
})

// 获取风格标签名称
const getStyleLabel = (type: string, value: string) => {
  const optionsMap: Record<string, any[]> = {
    visual: visualStyleOptions,
    color: colorToneOptions
  }
  const options = optionsMap[type] || []
  const option = options.find(o => o.value === value)
  return option?.label || value
}

const goBack = () => {
  router.push(`/dramas/${dramaId}`)
}

const addCharacter = () => {
  Object.assign(editForm, {
    name: '',
    role: '',
    personality: '',
    appearance: '',
    background: '',
    visualStyle: '',
    colorTone: ''
  })
  editDialogVisible.value = true
}

const saveCharacters = async () => {
  saving.value = true
  try {
    // TODO: 调用保存角色API
    await new Promise(resolve => setTimeout(resolve, 1000))
    ElMessage.success('保存成功')
  } catch (error: any) {
    ElMessage.error(error.message || '保存失败')
  } finally {
    saving.value = false
  }
}

const editCharacter = (character: Character) => {
  Object.assign(editForm, {
    ...character,
    visualStyle: (character as any).visualStyle || '',
    colorTone: (character as any).colorTone || ''
  })
  editDialogVisible.value = true
}

const saveCharacter = () => {
  // 生成风格提示词
  const styleParts: string[] = []
  if (editForm.visualStyle) {
    const opt = visualStyleOptions.find(o => o.value === editForm.visualStyle)
    if (opt) styleParts.push(opt.label)
  }
  if (editForm.colorTone) {
    const opt = colorToneOptions.find(o => o.value === editForm.colorTone)
    if (opt) styleParts.push(opt.label)
  }

  // 将风格信息保存到角色数据中
  const stylePrompt = styleParts.join('，')
  console.log('保存角色风格:', stylePrompt)

  // TODO: 保存角色信息到后端
  editDialogVisible.value = false
  ElMessage.success('保存成功')
}

const generateCharacterImage = (character: Character) => {
  router.push(`/dramas/${dramaId}/images/characters?character=${character.id}`)
}

const goToNextStep = () => {
  router.push(`/dramas/${dramaId}/images/characters`)
}

onMounted(() => {
  // TODO: 加载已有角色
})
</script>

<style scoped>
.character-extraction-container {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.main-card {
  margin-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h3 {
  margin: 0;
}

.character-card {
  margin-bottom: 20px;
}

.character-header {
  display: flex;
  gap: 16px;
  align-items: center;
}

.character-info h4 {
  margin: 0 0 8px 0;
}

.character-details p {
  margin: 8px 0;
  font-size: 14px;
  color: #606266;
}

.actions {
  margin-top: 30px;
  text-align: center;
}

/* 风格配置样式 */
.divider-text {
  font-size: 13px;
  font-weight: 500;
  color: var(--el-text-color-primary);
}

.style-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0 16px;
}

@media (max-width: 600px) {
  .style-grid {
    grid-template-columns: 1fr;
  }
}

.style-preview {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: var(--el-fill-color-light);
  border-radius: 6px;
  margin-top: 8px;
}

.preview-label {
  font-size: 13px;
  color: var(--el-text-color-secondary);
}
</style>
