import {
  normalizeValue,
  requiredValue,
  resolveValue,
  tokenKey,
} from './token-value-utils.mjs';

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
    ['subtle', 'color.background.subtle'],
    ['overlay', 'color.background.overlay'],
  ],
  border: [
    ['base', 'color.border.base'],
    ['strong', 'color.border.strong'],
    ['focus', 'color.border.focus'],
    ['disabled', 'color.border.disabled'],
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
    ['success.foreground', 'color.status.success.foreground'],
    ['success.background', 'color.status.success.background'],
    ['success.border', 'color.status.success.border'],
    ['success.strong', 'color.status.success.strong'],
    ['success.onStrong', 'color.status.success.onStrong'],
    ['warning.foreground', 'color.status.warning.foreground'],
    ['warning.background', 'color.status.warning.background'],
    ['warning.border', 'color.status.warning.border'],
    ['warning.strong', 'color.status.warning.strong'],
    ['warning.onStrong', 'color.status.warning.onStrong'],
    ['error.foreground', 'color.status.error.foreground'],
    ['error.background', 'color.status.error.background'],
    ['error.border', 'color.status.error.border'],
    ['error.strong', 'color.status.error.strong'],
    ['error.onStrong', 'color.status.error.onStrong'],
    ['info.foreground', 'color.status.info.foreground'],
    ['info.background', 'color.status.info.background'],
    ['info.border', 'color.status.info.border'],
    ['info.strong', 'color.status.info.strong'],
    ['info.onStrong', 'color.status.info.onStrong'],
  ],
  surface: [
    ['base', 'color.surface.base'],
    ['tinted', 'color.surface.tinted'],
    ['raised', 'color.surface.raised'],
    ['hover', 'color.surface.hover'],
    ['pressed', 'color.surface.pressed'],
    ['disabled', 'color.surface.disabled'],
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

function assignNestedField(target, fieldPath, value) {
  const segments = fieldPath.split('.');
  let cursor = target;

  for (const segment of segments.slice(0, -1)) {
    cursor[segment] ??= {};
    cursor = cursor[segment];
  }

  cursor[segments.at(-1)] = value;
}

function objectFromFieldMap(fields, tokenValues) {
  const object = {};

  for (const [name, tokenPath] of fields) {
    assignNestedField(object, name, requiredValue(tokenValues, tokenPath));
  }

  return object;
}

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

  if (Array.isArray(options.fonts) && options.fonts.length > 0) {
    manifest.fonts = options.fonts.map((font) => ({
      family: font.family,
      source: font.destination,
      weight: font.weight,
      style: font.style ?? 'normal',
      required: font.required !== false,
    }));
  }

  manifest.colors = Object.fromEntries(
    Object.entries(COLOR_FIELD_MAP).map(([groupName, fields]) => [
      groupName,
      objectFromFieldMap(fields, tokenValues),
    ]),
  );

  for (const [section, fields] of Object.entries(FIELD_MAP)) {
    manifest[section] = Object.fromEntries(
      fields.map(([name, tokenPath]) => [name, requiredValue(tokenValues, tokenPath)]),
    );
  }

  return manifest;
}
