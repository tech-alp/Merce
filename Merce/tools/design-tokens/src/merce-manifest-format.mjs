import { resolveReferences } from 'style-dictionary/utils';

export const COLOR_FIELD_MAP = {
  text: [
    ['primary', 'color.text.primary'],
    ['secondary', 'color.text.secondary'],
    ['tertiary', 'color.text.tertiary'],
    ['inverse', 'color.text.inverse'],
    ['disabled', 'color.text.disabled'],
    ['link', 'color.text.link'],
    ['linkHover', 'color.text.linkHover'],
  ],
  background: [
    ['base', 'color.background.base'],
    ['surface', 'color.background.surface'],
    ['elevated', 'color.background.elevated'],
    ['hover', 'color.background.hover'],
    ['pressed', 'color.background.pressed'],
    ['tinted', 'color.background.tinted'],
    ['overlay', 'color.background.overlay'],
  ],
  border: [
    ['base', 'color.border.base'],
    ['strong', 'color.border.strong'],
    ['focus', 'color.border.focus'],
    ['error', 'color.border.error'],
    ['success', 'color.border.success'],
  ],
  action: [
    ['primary', 'color.action.primary'],
    ['primaryHover', 'color.action.primaryHover'],
    ['primaryPressed', 'color.action.primaryPressed'],
    ['primarySubtle', 'color.action.primarySubtle'],
    ['secondary', 'color.action.secondary'],
    ['secondaryHover', 'color.action.secondaryHover'],
    ['secondaryPressed', 'color.action.secondaryPressed'],
    ['disabled', 'color.action.disabled'],
  ],
  status: [
    ['success', 'color.status.success'],
    ['successSubtle', 'color.status.successSubtle'],
    ['warning', 'color.status.warning'],
    ['warningSubtle', 'color.status.warningSubtle'],
    ['error', 'color.status.error'],
    ['errorSubtle', 'color.status.errorSubtle'],
    ['info', 'color.status.info'],
    ['infoSubtle', 'color.status.infoSubtle'],
  ],
  surface: [
    ['base', 'color.surface.base'],
    ['tinted', 'color.surface.tinted'],
    ['raised', 'color.surface.raised'],
  ],
};

export const FIELD_MAP = {
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

  manifest.colors = Object.fromEntries(
    Object.entries(COLOR_FIELD_MAP).map(([groupName, fields]) => [
      groupName,
      Object.fromEntries(
        fields.map(([name, tokenPath]) => [name, requiredValue(tokenValues, tokenPath)]),
      ),
    ]),
  );

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
