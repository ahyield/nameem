// Shrinks photos in the browser before upload. Phone photos are often 3–12 MB, which made uploads on
// mobile data slow enough to look broken; 2000px on the long side is plenty for an article.
export const MAX_DIMENSION = 2000
export const MAX_UNTOUCHED_BYTES = 1.5 * 1024 * 1024
export const ACCEPTED_TYPES = "image/jpeg,image/png,image/webp,image/gif"
const JPEG_QUALITY = 0.85

// Width and height scaled down to fit maxDimension, never up
export function fitWithin(width, height, maxDimension = MAX_DIMENSION) {
  const scale = Math.min(1, maxDimension / Math.max(width, height))
  return { width: Math.round(width * scale), height: Math.round(height * scale) }
}

// Animated GIFs are kept as they are; small images that already fit are uploaded untouched
export function needsResize({ type, size, width, height }) {
  if (type === "image/gif") return false
  return size > MAX_UNTOUCHED_BYTES || Math.max(width, height) > MAX_DIMENSION
}

// PNGs keep transparency; everything else becomes JPEG
export function outputType(type) {
  return type === "image/png" ? "image/png" : "image/jpeg"
}

export function renamed(name, type) {
  const base = name.replace(/\.[^.]+$/, "") || "image"
  return `${base}.${type === "image/png" ? "png" : "jpg"}`
}

// Returns the file to upload: the original, or a resized copy (rotation from the photo's EXIF is applied)
export async function prepareImage(file) {
  if (file.type === "image/gif") return file

  const bitmap = await createImageBitmap(file, { imageOrientation: "from-image" })
  if (!needsResize({ type: file.type, size: file.size, width: bitmap.width, height: bitmap.height })) {
    bitmap.close?.()
    return file
  }

  const { width, height } = fitWithin(bitmap.width, bitmap.height)
  const canvas = document.createElement("canvas")
  canvas.width = width
  canvas.height = height
  canvas.getContext("2d").drawImage(bitmap, 0, 0, width, height)
  bitmap.close?.()

  const type = outputType(file.type)
  const blob = await new Promise((resolve) => canvas.toBlob(resolve, type, JPEG_QUALITY))
  if (!blob) return file

  return new File([blob], renamed(file.name, type), { type, lastModified: Date.now() })
}
