import { resolveReferences } from 'style-dictionary/utils';

export const FIELD_MAP = {
  palette: [
    ['textPrimary', 'palette.semantic.textPrimary'],
    ['textSecondary', 'palette.semantic.textSecondary'],
    ['textTertiary', 'palette.semantic.textTertiary'],
    ['textInverse', 'palette.semantic.textInverse'],
    ['link', 'palette.semantic.link'],
    ['backgroundBase', 'palette.semantic.backgroundBase'],
    ['backgroundSurface', 'palette.semantic.backgroundSurface'],
    ['backgroundElevated', 'palette.semantic.backgroundElevated'],
    ['backgroundHover', 'palette.semantic.backgroundHover'],
    ['backgroundPressed', 'palette.semantic.backgroundPressed'],
    ['actionPrimary', 'palette.semantic.actionPrimary'],
    ['actionPrimaryLight', 'palette.semantic.actionPrimaryLight'],
    ['actionPrimaryDark', 'palette.semantic.actionPrimaryDark'],
    ['actionSecondary', 'palette.semantic.actionSecondary'],
    ['borderBase', 'palette.semantic.borderBase'],
    ['borderStrong', 'palette.semantic.borderStrong'],
    ['borderFocus', 'palette.semantic.borderFocus'],
    ['statusError', 'palette.semantic.statusError'],
    ['statusSuccess', 'palette.semantic.statusSuccess'],
    ['statusWarning', 'palette.semantic.statusWarning'],
    ['statusInfo', 'palette.semantic.statusInfo'],
    ['surfaceBase', 'palette.semantic.surfaceBase'],
    ['surfaceTinted', 'palette.semantic.surfaceTinted'],
  ],
  spacing: [
    'base',
    'none',
    'xxs',
    'xs',
    'sm',
    'md',
    'lg',
    'xl',
    'xl2',
    'xl3',
    'xl4',
    'xl5',
    'xl6',
    'componentGap',
    'sectionGap',
    'pagePadding',
    'touchTarget',
    'touchTargetCompact',
    'gridGap',
    'stackGap',
    'inlineGap',
  ].map((name) => [name, `spacing.${name}`]),
  radius: [
    'none',
    'small',
    'medium',
    'large',
    'xlarge',
    'xxlarge',
    'full',
    'button',
    'input',
    'card',
    'badge',
    'dialog',
    'tooltip',
  ].map((name) => [name, `radius.${name}`]),
  typography: [
    'displayFont',
    'bodyFont',
    'monoFont',
    'displayFontFallback',
    'bodyFontFallback',
    'sizeXSmall',
    'sizeSmall',
    'sizeMedium',
    'sizeLarge',
    'sizeXLarge',
    'size2XLarge',
    'size3XLarge',
    'size4XLarge',
    'size5XLarge',
    'size6XLarge',
    'size7XLarge',
    'weightRegular',
    'weightMedium',
    'weightSemibold',
    'weightBold',
    'leadingTight',
    'leadingSnug',
    'leadingNormal',
    'leadingRelaxed',
    'trackingTight',
    'trackingNormal',
    'trackingWide',
    'trackingWider',
    'trackingWidest',
  ].map((name) => [name, `typography.${name}`]),
};

export function formatMerceManifest(dictionary, options) {
  const tokenValues = new Map(
    dictionary.allTokens.map((token) => [
      tokenKey(token),
      normalizeValue(resolveValue(token, dictionary.tokens)),
    ]),
  );

  const manifest = {
    schemaVersion: 1,
    theme: options.theme,
  };

  if (options.variant) {
    manifest.variant = options.variant;
  }

  for (const [section, fields] of Object.entries(FIELD_MAP)) {
    manifest[section] = Object.fromEntries(
      fields.map(([name, tokenPath]) => [name, requiredValue(tokenValues, tokenPath)]),
    );
  }

  return manifest;
}

function requiredValue(values, tokenPath) {
  if (!values.has(tokenPath)) {
    throw new Error(`Missing token '${tokenPath}' required by Merce manifest format`);
  }

  return values.get(tokenPath);
}

function normalizeValue(value) {
  if (typeof value === 'string' && /^-?\d+(\.\d+)?$/.test(value)) {
    return Number(value);
  }

  return value;
}

function tokenKey(token) {
  if (Array.isArray(token.path)) {
    return token.path.join('.');
  }

  if (typeof token.key === 'string') {
    return token.key.replace(/^\{|\}$/g, '');
  }

  throw new Error(`Token has no path metadata: ${JSON.stringify(token)}`);
}

function resolveValue(token, tokens) {
  const value = token.value ?? token.$value;
  if (typeof value === 'string' && value.includes('{')) {
    return resolveReferences(value, tokens, { usesDtcg: true });
  }

  return value;
}
