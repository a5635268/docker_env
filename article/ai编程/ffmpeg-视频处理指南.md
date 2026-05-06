# ffmpeg 视频处理指南

> 业界标准的多媒体处理工具，支持视频转换、剪辑、压缩等

---

## 概述

ffmpeg 是开源的跨平台多媒体处理框架：

- ✅ **全格式支持** - 几乎所有视频/音频格式
- ✅ **强大编码器** - H.264、H.265、AV1、VP9 等
- ✅ **流处理** - 支持流式转换和推流
- ✅ **滤镜丰富** - 内置大量视频/音频滤镜
- ✅ **命令行驱动** - 适合自动化和脚本

---

## 安装

```bash
# Homebrew 安装 (macOS)
brew install ffmpeg

# 验证安装
ffmpeg -version
```

---

## 基础用法

### 格式转换

```bash
# 转换为 MP4
ffmpeg -i input.avi output.mp4

# 指定编码器
ffmpeg -i input.mov -c:v libx264 -c:a aac output.mp4

# 转换为 WebM
ffmpeg -i input.mp4 -c:v libvpx -c:a libvorbis output.webm
```

### 视频压缩

```bash
# CRF 质量控制（0-51，越小质量越高）
ffmpeg -i input.mp4 -c:v libx264 -crf 23 output.mp4

# 指定比特率
ffmpeg -i input.mp4 -b:v 1M -b:a 128k output.mp4

# H.265 压缩（更小体积）
ffmpeg -i input.mp4 -c:v libx265 -crf 28 output.mp4
```

---

## 常用操作

### 视频剪辑

```bash
# 截取片段（从 10 秒开始，持续 30 秒）
ffmpeg -i input.mp4 -ss 10 -t 30 -c copy output.mp4

# 截取到指定时间点
ffmpeg -i input.mp4 -ss 00:01:00 -to 00:02:00 -c copy output.mp4

# 快速截取（不重新编码）
ffmpeg -i input.mp4 -ss 10 -t 30 output.mp4
```

### 视频合并

```bash
# 使用 concat 文件
echo "file 'part1.mp4'
file 'part2.mp4'" > list.txt
ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp4

# 直接拼接（相同编码）
ffmpeg -i "concat:part1.mp4|part2.mp4" -c copy output.mp4
```

### 提取音频

```bash
# 提取音频为 MP3
ffmpeg -i video.mp4 -vn -c:a libmp3lame -q:a 2 audio.mp3

# 提取音频为 AAC
ffmpeg -i video.mp4 -vn -c:a aac audio.aac

# 仅保留视频（去除音频）
ffmpeg -i video.mp4 -an -c:v copy video_only.mp4
```

### 视频缩放

```bash
# 指定分辨率
ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4

# 保持比例缩放宽度
ffmpeg -i input.mp4 -vf scale=1280:-2 output.mp4

# 缩放高度
ffmpeg -i input.mp4 -vf scale=-2:720 output.mp4
```

---

## 滤镜操作

### 添加水印

```bash
# 图片水印
ffmpeg -i video.mp4 -i watermark.png \
  -filter_complex "overlay=10:10" output.mp4

# 文字水印
ffmpeg -i video.mp4 \
  -vf "drawtext=text='My Video':fontcolor=white:fontsize=24:x=10:y=10" \
  output.mp4
```

### 视频裁剪

```bash
# 裁剪画面区域
ffmpeg -i input.mp4 -vf "crop=1920:1080:0:0" output.mp4

# 自动检测黑边裁剪
ffmpeg -i input.mp4 -vf "cropdetect" -f null -  # 检测参数
ffmpeg -i input.mp4 -vf "crop=1920:800:0:140" output.mp4
```

### 调整速度

```bash
# 加速 2 倍
ffmpeg -i input.mp4 -vf "setpts=0.5*PTS" -af "atempo=2.0" output.mp4

# 减速 0.5 倍
ffmpeg -i input.mp4 -vf "setpts=2*PTS" -af "atempo=0.5" output.mp4
```

---

## 使用场景

### 1. 功能演示视频制作

```bash
# 录制屏幕后压缩
ffmpeg -i screen_record.mov \
  -c:v libx264 -crf 23 \
  -preset medium \
  -c:a aac -b:a 128k \
  demo.mp4
```

### 2. GIF 转换

```bash
# 视频转 GIF（简单）
ffmpeg -i video.mp4 -vf scale=320:-1 output.gif

# 优化 GIF（高质量）
ffmpeg -i video.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" \
  -c:v gif output.gif
```

### 3. 批量转换

```bash
# 批量转换目录下所有视频
for f in *.avi; do
  ffmpeg -i "$f" -c:v libx264 -c:a aac "${f%.avi}.mp4"
done
```

### 4. 视频元数据处理

```bash
# 查看视频信息
ffmpeg -i video.mp4

# 提取元数据
ffprobe -v quiet -print_format json -show_format -show_streams video.mp4

# 移除所有元数据
ffmpeg -i input.mp4 -map_metadata -1 output.mp4
```

---

## AI Agent 工作流

### 快速视频处理

```bash
# 压缩演示视频
ffmpeg -i raw_demo.mov \
    -c:v libx264 -crf 28 -preset fast \
    -c:a aac -b:a 96k \
    -movflags +faststart \
    demo.mp4
```

### 格式转换（兼容性）

```bash
# 生成兼容性最好的 MP4
ffmpeg -i source.mkv \
    -c:v libx264 -profile:v baseline -level 3.0 \
    -c:a aac -b:a 128k \
    -vf scale=1280:-2 \
    -movflags +faststart \
    compatible.mp4
```

---

## 常用参数表

| 参数 | 说明 | 示例 |
|------|------|------|
| `-i` | 输入文件 | `-i input.mp4` |
| `-c:v` | 视频编码器 | `-c:v libx264` |
| `-c:a` | 音频编码器 | `-c:a aac` |
| `-b:v` | 视频比特率 | `-b:v 1M` |
| `-b:a` | 音频比特率 | `-b:a 128k` |
| `-crf` | 质量因子 | `-crf 23` |
| `-vf` | 视频滤镜 | `-vf scale=720:-2` |
| `-af` | 音频滤镜 | `-af volume=2` |
| `-ss` | 开始时间 | `-ss 00:01:00` |
| `-t` | 持续时间 | `-t 30` |
| `-preset` | 编码速度 | `-preset fast` |

---

## 常见问题

### Q: 转换后体积更大？

使用更低的 CRF 值或指定比特率：
```bash
ffmpeg -i input.mp4 -c:v libx264 -crf 28 output.mp4
```

### Q: 音视频不同步？

重新编码音频：
```bash
ffmpeg -i input.mp4 -c:v copy -c:a aac -strict experimental output.mp4
```

### Q: 编码太慢？

使用 faster/ultrafast preset：
```bash
ffmpeg -i input.mp4 -c:v libx264 -preset faster output.mp4
```

---

## 参考链接

- [ffmpeg 官网](https://ffmpeg.org/)
- [官方文档](https://ffmpeg.org/documentation.html)
- [滤镜文档](https://ffmpeg.org/ffmpeg-filters.html)