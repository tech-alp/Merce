#!/usr/bin/env node

import { spawn } from "node:child_process";

const repoRoot = new URL("..", import.meta.url).pathname.replace(/\/$/, "");
const mcpPath = `${repoRoot}/build/qmlagent/tools/qmlagent/qmlagent-mcp`;
const port = Number(process.argv[2] ?? "3771");

let nextId = 1;
let stdoutBuffer = "";
let stderrBuffer = "";
const pending = new Map();
const notifications = [];

const child = spawn(mcpPath, ["--timeout", "10000"], {
  cwd: repoRoot,
});

child.stdout.on("data", (chunk) => {
  stdoutBuffer += chunk.toString("utf8");
  let newline;
  while ((newline = stdoutBuffer.indexOf("\n")) >= 0) {
    const line = stdoutBuffer.slice(0, newline).trim();
    stdoutBuffer = stdoutBuffer.slice(newline + 1);
    if (!line) {
      continue;
    }

    let message;
    try {
      message = JSON.parse(line);
    } catch (error) {
      notifications.push({ parseError: String(error), line });
      continue;
    }

    if (message.id !== undefined && pending.has(message.id)) {
      pending.get(message.id)(message);
      pending.delete(message.id);
    } else {
      notifications.push(message);
    }
  }
});

child.stderr.on("data", (chunk) => {
  stderrBuffer += chunk.toString("utf8");
});

function request(method, params = {}) {
  const id = nextId++;
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);

  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      pending.delete(id);
      reject(new Error(`Timed out waiting for ${method}`));
    }, 15000);

    pending.set(id, (message) => {
      clearTimeout(timer);
      resolve(message);
    });
  });
}

function notify(method, params = {}) {
  child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", method, params })}\n`);
}

function tool(name, args = {}) {
  return request("tools/call", { name, arguments: args });
}

function payload(response) {
  return response?.result?.structuredContent ?? response?.result ?? response;
}

function summarizeQuery(query) {
  if (query.error) {
    return { error: query.error };
  }

  return {
    matchCount: query.matchCount,
    diagnostics: query.diagnostics?.map((diagnostic) => ({
      id: diagnostic.id,
      severity: diagnostic.severity,
      message: diagnostic.message,
    })),
    matches: query.matches?.slice(0, 3).map((match) => ({
      nodeId: match.nodeId,
      qmlId: match.qmlId,
      objectName: match.objectName,
      type: match.type,
      text: match.text,
      bbox: match.bbox,
      insideViewport: match.insideViewport,
      properties: match.properties,
      sourceLocation: match.sourceLocation && {
        file: match.sourceLocation.file,
        line: match.sourceLocation.line,
        confidence: match.sourceLocation.confidence,
      },
    })),
  };
}

function summarizeDiagnostics(diagnostics) {
  if (diagnostics.error) {
    return { error: diagnostics.error };
  }

  return {
    summary: diagnostics.summary,
    issues: diagnostics.issues?.slice(0, 8).map((issue) => ({
      id: issue.id,
      severity: issue.severity,
      message: issue.message,
      nodeId: issue.nodeId,
      sourceLocation: issue.sourceLocation && {
        file: issue.sourceLocation.file,
        line: issue.sourceLocation.line,
        confidence: issue.sourceLocation.confidence,
      },
    })),
  };
}

try {
  const init = await request("initialize", {
    protocolVersion: "2024-11-05",
    capabilities: {},
    clientInfo: { name: "merce-qmlagent-probe", version: "local" },
  });
  notify("notifications/initialized");

  const connect = await tool("qmlagent.connect_tcp", {
    host: "127.0.0.1",
    port,
    timeoutMs: 10000,
  });

  const status = await tool("qmlagent.target_status", {});
  const gallerySelectors = [
    ["root", 'objectName="merce.playground.gallery"', ["width", "height", "visible"]],
    ["activeTheme", 'objectName="merce.playground.gallery.activeTheme"', ["width", "height", "visible"]],
    ["palette", 'objectName="merce.playground.gallery.palette"', ["width", "height", "visible"]],
    ["typography", 'objectName="merce.playground.gallery.typography"', ["width", "height", "visible"]],
    ["spacingRadius", 'objectName="merce.playground.gallery.spacingRadius"', ["width", "height", "visible"]],
    ["components", 'objectName="merce.playground.gallery.components"', ["width", "height", "visible"]],
    ["exportStatus", 'objectName="merce.playground.gallery.exportStatus"', ["width", "height", "visible"]],
  ];
  const gallery = {};
  for (const [name, selector, properties] of gallerySelectors) {
    gallery[name] = await tool("qmlagent.ui_query", {
      selector,
      verbosity: "summary",
      includeSource: true,
      properties,
    });
  }
  const tree = await tool("qmlagent.ui_get_tree", {
    depth: 3,
    maxNodes: 80,
    fields: ["nodeId", "id", "type", "objectName", "text", "visible", "enabled", "bounds"],
    properties: ["width", "height", "title"],
  });
  const diagnostics = await tool("qmlagent.diagnostics_analyze_tree", {
    maxIssues: 10,
    verbosity: "summary",
  });

  const connectPayload = payload(connect);
  const statusPayload = payload(status);
  const treePayload = payload(tree);
  const diagnosticsPayload = payload(diagnostics);
  const galleryPayload = Object.fromEntries(
    Object.entries(gallery).map(([name, response]) => [name, summarizeQuery(payload(response))]),
  );

  await request("shutdown");
  notify("notifications/exit");
  child.stdin.end();

  console.log(JSON.stringify({
    init: init.result?.serverInfo,
    connect: {
      connected: connectPayload.connected,
      serviceEnabled: connectPayload.serviceEnabled,
      host: connectPayload.host,
      port: connectPayload.port,
    },
    status: {
      connected: statusPayload.connected,
      serviceEnabled: statusPayload.serviceEnabled,
      recentLogEntryCount: statusPayload.recentLogEntryCount,
      recentLogEntries: statusPayload.recentLogEntries?.slice(0, 3),
    },
    gallery: galleryPayload,
    tree: {
      nodeCount: treePayload.nodeCount,
      windows: treePayload.windows?.map((window) => ({
        title: window.title,
        width: window.width,
        height: window.height,
        windowId: window.windowId,
      })),
    },
    diagnostics: summarizeDiagnostics(diagnosticsPayload),
    stderr: stderrBuffer.trim(),
    notificationCount: notifications.length,
  }, null, 2));
} catch (error) {
  child.kill();
  console.error(error.message);
  process.exit(1);
}
