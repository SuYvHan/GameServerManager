// 用户相关类型
export interface User {
  id: string
  username: string
  role: 'admin' | 'user'
  createdAt: string
  lastLogin?: string
  loginAttempts: number
  lockedUntil?: string
}

export interface LoginRequest {
  username: string
  password: string
  captchaId?: string
  captchaCode?: string
}

export interface LoginResponse {
  success: boolean
  message: string
  token?: string
  user?: User
  requireCaptcha?: boolean
}

export interface RegisterRequest {
  username: string
  password: string
}

export interface RegisterResponse {
  success: boolean
  message: string
  user?: User
}

export interface HasUsersResponse {
  success: boolean
  hasUsers: boolean
}

export interface CaptchaData {
  id: string
  svg: string
}

export interface CaptchaResponse {
  success: boolean
  captcha: CaptchaData
}

export interface CheckCaptchaResponse {
  success: boolean
  requireCaptcha: boolean
}

export interface AuthState {
  isAuthenticated: boolean
  user: User | null
  token: string | null
  loading: boolean
  error: string | null
}

// 主题相关类型
export type Theme = 'light' | 'dark'

export interface ThemeState {
  theme: Theme
  toggleTheme: () => void
}

// 终端相关类型
export interface TerminalSession {
  id: string
  name: string
  active: boolean
  createdAt: string
  lastActivity: string
}

export interface TerminalState {
  sessions: TerminalSession[]
  activeSessionId: string | null
  connected: boolean
  loading: boolean
}

// 系统信息类型
export interface SystemStats {
  cpu: {
    usage: number
    cores: number
    model: string
  }
  memory: {
    total: number
    used: number
    free: number
    usage: number
  }
  disk: {
    total: number
    used: number
    free: number
    usage: number
  }
  network: {
    rx: number
    tx: number
  }
  uptime: number
  timestamp: string
}

export interface SystemInfo {
  platform: string
  arch: string
  hostname: string
  ipv4: string[]
  ipv6: string[]
  version: string
  nodeVersion: string
}

export interface ProcessInfo {
  id: string
  pid: number
  name: string
  cpu: number
  memory: number
  status: string
  startTime: string
  command: string
}

export interface SystemAlert {
  id: string
  type: 'cpu' | 'memory' | 'disk' | 'network' | 'process'
  level: 'info' | 'warning' | 'critical'
  message: string
  value: number
  threshold: number
  timestamp: string
  resolved: boolean
}

export interface ActivePort {
  port: number
  protocol: 'tcp' | 'udp'
  state: string
  process?: string
  pid?: number
  address: string
}

// 游戏相关类型
export interface GameServer {
  id: string
  name: string
  type: string
  status: 'running' | 'stopped' | 'starting' | 'stopping' | 'error'
  port: number
  players: {
    current: number
    max: number
  }
  uptime: number
  lastUpdate: string
}

export interface GameConfig {
  name: string
  type: string
  port: number
  maxPlayers: number
  autoStart: boolean
  restartOnCrash: boolean
  customArgs: string[]
}

// API响应类型
export interface ApiResponse<T = any> {
  success: boolean
  message?: string
  data?: T
  error?: string
}

// Socket事件类型
export interface SocketEvents {
  // 终端事件
  'terminal-output': (data: { sessionId: string; data: string }) => void
  'terminal-created': (data: { sessionId: string; name: string }) => void
  'terminal-closed': (data: { sessionId: string }) => void
  
  // 系统监控事件
  'system-stats': (data: SystemStats) => void
  'system-alert': (data: SystemAlert) => void
  'system-alert-resolved': (data: SystemAlert) => void
  
  // 游戏服务器事件
  'game-status': (data: { gameId: string; status: GameServer['status'] }) => void
  'game-players': (data: { gameId: string; players: { current: number; max: number } }) => void
  'game-output': (data: { gameId: string; output: string }) => void
}

// 导航相关类型
export interface NavItem {
  id: string
  label: string
  icon: React.ComponentType<any>
  path: string
  requireAuth?: boolean
  adminOnly?: boolean
}

// 通知类型
export interface Notification {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message: string
  duration?: number
  timestamp: string
}

export interface NotificationState {
  notifications: Notification[]
  addNotification: (notification: Omit<Notification, 'id' | 'timestamp'>) => void
  removeNotification: (id: string) => void
  clearNotifications: () => void
}

// 天气相关类型
export interface WeatherData {
  cityInfo: {
    city: string
    cityId: string
    parent: string
    updateTime: string
  }
  wendu: string
  shidu: string
  pm25: number
  pm10: number
  quality: string
  ganmao: string
  forecast: Array<{
    date: string
    ymd: string
    week: string
    sunrise: string
    high: string
    low: string
    sunset: string
    aqi: number
    fx: string
    fl: string
    type: string
    notice: string
  }>
  yesterday: {
    date: string
    ymd: string
    week: string
    sunrise: string
    high: string
    low: string
    sunset: string
    aqi: number
    fx: string
    fl: string
    type: string
    notice: string
  }
  selectedCityCode?: string // 用户选择的城市代码
}

// 设置相关类型
export interface AppSettings {
  theme: Theme
  language: 'zh-CN' | 'en-US'
  autoSave: boolean
  notifications: {
    desktop: boolean
    sound: boolean
    system: boolean
    games: boolean
  }
  terminal: {
    fontSize: number
    fontFamily: string
    theme: 'dark' | 'light'
    cursorBlink: boolean
    scrollback: number
  }
  dashboard: {
    refreshInterval: number
    showSystemStats: boolean
    showGameServers: boolean
    compactMode: boolean
  }
}

export interface SettingsState {
  settings: AppSettings
  updateSettings: (updates: Partial<AppSettings>) => void
  resetSettings: () => void
  loading: boolean
  error: string | null
}

// 实例管理相关类型
export interface Instance {
  id: string
  name: string
  description: string
  workingDirectory: string
  startCommand: string
  autoStart: boolean
  stopCommand: 'ctrl+c' | 'stop' | 'exit'
  status: 'running' | 'stopped' | 'starting' | 'stopping' | 'error'
  pid?: number
  createdAt: string
  lastStarted?: string
  lastStopped?: string
  enableStreamForward?: boolean
  programPath?: string
  terminalSessionId?: string
}

export interface CreateInstanceRequest {
  name: string
  description: string
  workingDirectory: string
  startCommand: string
  autoStart: boolean
  stopCommand: 'ctrl+c' | 'stop' | 'exit'
  enableStreamForward?: boolean
  programPath?: string
}

export interface InstanceState {
  instances: Instance[]
  loading: boolean
  error: string | null
}

// 平台类型枚举
export enum Platform {
  WINDOWS = 'windows',
  LINUX = 'linux',
  MACOS = 'macos'
}

// 更多游戏信息类型
export interface MoreGameInfo {
  id: string
  name: string
  description: string
  icon: string
  category: string
  supported: boolean
  supportedPlatforms: Platform[]
  currentPlatform?: Platform
  supportedOnCurrentPlatform?: boolean
}

// 游戏部署相关类型
export interface InstallableGame {
  id: string
  name: string
  appid: string
  hint: string
  image: string
  url: string
  system?: Platform[]
  supportedOnCurrentPlatform?: boolean
  currentPlatform?: Platform
}

export interface GameInstallRequest {
  gameId: string
  installPath: string
}

export interface GameInstallProgress {
  type: 'progress' | 'success' | 'error'
  message: string
  progress?: number
  instanceId?: string
}

// Minecraft服务端相关类型
export interface MinecraftServerCategory {
  name: string
  displayName: string
  servers: string[]
}

export interface MinecraftDownloadOptions {
  server: string
  version: string
  targetDirectory: string
  skipJavaCheck?: boolean
  skipServerRun?: boolean
}

export interface MinecraftDownloadProgress {
  loaded: number
  total: number
  percentage: number
}

export interface MinecraftDownloadInfo {
  url: string
  sha256: string
}

// 文件管理相关类型
export * from './file'