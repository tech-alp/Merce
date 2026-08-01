#!/usr/bin/env node

import { spawn } from "node:child_process"
import { writeFileSync } from "node:fs"

const repo = new URL("..", import.meta.url).pathname.replace(/\/$/, "")
const port = Number(process.argv[2] ?? "0")
const mcp = spawn(`${repo}/build/qmlagent/tools/qmlagent/qmlagent-mcp`, ["--timeout", "10000"], { cwd: repo })
let id = 0
let buffer = ""
const pending = new Map()

mcp.stdout.on("data", chunk => {
    buffer += chunk.toString()
    for (;;) {
        const end = buffer.indexOf("\n")
        if (end < 0)
            break
        const line = buffer.slice(0, end).trim()
        buffer = buffer.slice(end + 1)
        if (!line)
            continue
        const message = JSON.parse(line)
        if (pending.has(message.id)) {
            pending.get(message.id)(message)
            pending.delete(message.id)
        }
    }
})

function request(method, params = {}) {
    const requestId = ++id
    mcp.stdin.write(JSON.stringify({ jsonrpc: "2.0", id: requestId, method, params }) + "\n")
    return new Promise((resolve, reject) => {
        const timer = setTimeout(() => reject(new Error(`timeout: ${method}`)), 15000)
        pending.set(requestId, message => {
            clearTimeout(timer)
            if (message.error)
                reject(new Error(JSON.stringify(message.error)))
            else
                resolve(message.result)
        })
    })
}

async function tool(name, args = {}) {
    const result = await request("tools/call", { name, arguments: args })
    const payload = result?.structuredContent ?? result
    if (payload && result?.content)
        payload.content = result.content
    if (payload?.error)
        throw new Error(`${name}: ${payload.error}`)
    return payload
}

async function query(selector, properties = []) {
    const result = await tool("qmlagent_ui_query", {
        selector,
        includeSource: true,
        properties,
        verbosity: "evidence"
    })
    return result.matches ?? []
}

async function capture(name) {
    const result = await tool("qmlagent_render_capture_screenshot", { includeData: true, scale: 0.75 })
    const data = result.data ?? result.content?.find(item => item.type === "image")?.data
    if (!data) {
        console.error("screenshot payload:", JSON.stringify(result))
        return
    }
    writeFileSync(`/private/tmp/${name}.png`, Buffer.from(data, "base64"))
}

async function navigate(key, selector) {
    await tool("qmlagent_runtime_invoke_method", {
        selector: 'objectName="merce.playground.window"',
        method: "navigateTo",
        args: [key]
    })
    const wait = await tool("qmlagent_ui_wait_for", { selector, until: { state: "found" }, timeoutMs: 3000 })
    if (!wait.ok)
        throw new Error(`navigation failed: ${key}`)
}

function one(matches, label) {
    if (matches.length !== 1)
        throw new Error(`${label}: expected one match, got ${matches.length}`)
    return matches[0]
}

function bottom(match) {
    return match.bbox[1] + match.bbox[3]
}

function right(match) {
    return match.bbox[0] + match.bbox[2]
}

await request("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "merce-layout-audit", version: "local" }
})
mcp.stdin.write(JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized", params: {} }) + "\n")
if (port > 0) {
    const connection = await tool("qmlagent_connect_tcp", { host: "127.0.0.1", port, timeoutMs: 10000 })
    if (!connection.connected)
        throw new Error(connection.lastError ?? "QMLAgent connection failed")
}
await tool("qmlagent_runtime_enable_mutation", { enabled: true })
for (const [property, value] of [["width", 1920], ["height", 1080]])
    await tool("qmlagent_runtime_set_property", { selector: 'objectName="merce.playground.window"', property, value })

const evidence = {}

await navigate("spacing", 'objectName="merce.playground.spacingRadiusShowcase"')
evidence.spacing = {
    card: await query('objectName="merce.playground.spacingRadius.pattern.dialog"', ["width", "height"]),
    cancel: await query('text="Cancel"', ["width", "height"]),
    confirm: await query('text="Confirm"', ["width", "height"])
}
const spacingCard = one(evidence.spacing.card, "spacing card")
for (const button of [...evidence.spacing.cancel, ...evidence.spacing.confirm]) {
    if (bottom(button) > bottom(spacingCard))
        throw new Error("spacing dialog actions exceed card")
}
await capture("merce-after-spacing")

await navigate("typography", 'objectName="merce.playground.typographyShowcase"')
evidence.typography = {
    root: await query('objectName="merce.playground.typographyShowcase"', ["width", "height", "compactLayout"]),
    table: await query('objectName="merce.playground.typography.scale"', ["width", "height"]),
    previewSpecs: await query('text="Preview / Specs"', ["width", "height"]),
    preview: await query('text="Preview"', ["width", "height"])
}
if (evidence.typography.previewSpecs.length !== 0 || evidence.typography.preview.length !== 1)
    throw new Error("typography wide header uses compact geometry")
await capture("merce-after-typography")

await navigate("shadows", 'objectName="merce.playground.shadowsShowcase"')
evidence.shadows = {
    scale: await query('objectName="merce.playground.shadows.scale"', ["width", "height"]),
    xlargeLayer0: await query('objectName="merce.playground.shadows.preview.xlarge.layer.0"'),
    xlargeLayer1: await query('objectName="merce.playground.shadows.preview.xlarge.layer.1"'),
    diagnostics: await tool("qmlagent_diagnostics_analyze_node", {
        selector: 'objectName="merce.playground.shadows.scale"',
        checks: ["insideViewport", "childExceedsParent", "overlap"]
    })
}
one(evidence.shadows.xlargeLayer0, "xlarge shadow layer 0")
one(evidence.shadows.xlargeLayer1, "xlarge shadow layer 1")
await capture("merce-after-shadows")

await navigate("feedback", 'objectName="merce.playground.feedbackShowcase"')
await tool("qmlagent_input_click", { selector: 'objectName="merce.playground.feedback.dialog.destructive"' })
await tool("qmlagent_ui_wait_for", { selector: 'objectName="MDialog"', until: { state: "found" }, timeoutMs: 3000 })
evidence.dialog = {
    outer: await query('objectName="MDialog"', ["width", "height", "padding", "availableWidth"]),
    content: await query('objectName="merce.playground.feedback.dialog.content"', ["width", "height"]),
    close: await query('objectName="merce.playground.feedback.dialog.close"', ["width", "height"]),
    cancel: await query('objectName="merce.playground.feedback.dialog.cancel"', ["width", "height"]),
    confirm: await query('objectName="merce.playground.feedback.dialog.confirm"', ["width", "height"])
}
const dialogOuter = one(evidence.dialog.outer, "dialog outer")
const dialogContent = one(evidence.dialog.content, "dialog content")
if (dialogContent.bbox[0] - dialogOuter.bbox[0] < 31
        || dialogContent.bbox[1] - dialogOuter.bbox[1] < 31
        || right(dialogOuter) - right(dialogContent) < 31
        || bottom(dialogOuter) - bottom(dialogContent) < 31)
    throw new Error("dialog content padding is below xl")
for (const control of [...evidence.dialog.close, ...evidence.dialog.cancel, ...evidence.dialog.confirm]) {
    if (control.bbox[0] < dialogContent.bbox[0]
            || control.bbox[1] < dialogContent.bbox[1]
            || right(control) > right(dialogContent)
            || bottom(control) > bottom(dialogContent))
        throw new Error("dialog control exceeds padded content")
}
await capture("merce-after-dialog")

console.log(JSON.stringify(evidence, null, 2))
await request("shutdown")
mcp.stdin.end()
